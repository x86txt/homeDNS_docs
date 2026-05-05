---
title: DNS Features
description: Authoritative zones, recursive resolver, forwarding strategies, filtering, DDNS, DNSSEC, and cache details.
---

import { Aside } from '@astrojs/starlight/components';

## Transport protocols

homeDNS supports all major DNS-over-X transports. Configure listeners in `listeners.*` in your YAML config.

| Transport | Protocol | Default port | YAML key | Status |
|-----------|----------|-------------|---------|--------|
| Do53 | DNS over UDP/TCP | 53 | `do53` | ✅ v1 |
| DoT | DNS over TLS (RFC 7858) | 853 | `dot` | ✅ v1 |
| DoH | DNS over HTTPS (RFC 8484) H1/H2 | 443 | `doh` | ✅ v1 |
| DoQ | DNS over QUIC (RFC 9250) | 853 | — | 🗓 Roadmap |
| DoH3 | DNS over HTTP/3 (RFC 9230) | 443 | — | 🗓 Roadmap |

Encrypted transports require TLS material in `tls.cert_file` / `tls.key_file`. DoH supports both POST (`application/dns-message`) and GET (`?dns=<base64url>`) per RFC 8484.

---

## Authoritative zones

homeDNS can serve as an authoritative name server for any zone you define.

### Record types

| Type | Description |
|------|-------------|
| A | IPv4 address |
| AAAA | IPv6 address |
| CNAME | Canonical name alias |
| MX | Mail exchanger |
| TXT | Text record (SPF, DKIM, DMARC, etc.) |
| SRV | Service locator |
| NS | Name server |
| SOA | Start of authority |
| PTR | Pointer (reverse DNS) |
| CAA | Certification authority authorization |

### Zone semantics

- **Forward and reverse zones** supported (e.g. `example.com` and `1.0.10.in-addr.arpa`)
- **Wildcards** (`*.example.com`) expand correctly
- **NXDOMAIN vs NODATA** distinction is preserved — a missing name returns `NXDOMAIN`; a name with no records of the requested type returns `NODATA`
- **Apex CNAME rejection** — CNAME at the zone apex (`@`) is rejected per RFC 1034
- **SOA serial** auto-increments on zone edits

### Zone import/export

Import and export use standard RFC 1035 zone file syntax. Import via API (`POST /api/v1/zones/{zone}/import`) or the web admin drag-and-drop.

---

## Recursive resolver

The iterative recursive resolver is built into `dnsd`. It chases delegations from the root down to authoritative servers.

### Key limits (configurable)

| Limit | Config key | Default |
|-------|-----------|---------|
| Max upstream queries per resolution | `recursion.max_queries` | 50 |
| Per-query timeout | `recursion.query_timeout` | 3s |
| CNAME chain depth | `recursion.max_cname_hops` | 8 |

### Resolver pipeline order

For each incoming query, `dnsd` evaluates:

1. **ACL** — drop or reject based on `acl.allow_query` / `acl.deny_query`
2. **Rate limit** — per-source token bucket
3. **Filter** — blocklist/allowlist check
4. **Cache** — return cached positive or negative response if present
5. **Authoritative** — serve answer from local zone if hosted
6. **Forward** — send to configured conditional forwarder matching the query zone
7. **Recurse** — iterative resolution if `recursion.enabled: true` and no forwarder matched

---

## Forwarding strategies

Each conditional forwarder has a **strategy** that controls how its upstream chain is queried.

| Strategy | Behaviour | Health-aware? |
|----------|-----------|--------------|
| `failover` | Try upstreams in order; skip failing ones | Yes — skips `failing` |
| `round_robin` | Rotate through upstreams in sequence | Yes — skips `failing` |
| `random` | Pick an upstream at random | Yes — skips `failing` |
| `parallel` | Race all upstreams; accept first valid response, cancel losers | Yes — deprioritises `slow` |
| `hedged` | Fire first upstream, then fire next after a delay derived from observed latency | Yes — uses RTT averages |

### `isAcceptable` logic (parallel and hedged)

A response is accepted as the winner only if:

| Rcode | Accepted? |
|-------|-----------|
| `NOERROR` with answers | ✅ |
| `NOERROR` (NODATA — no records of requested type) | ✅ |
| `NXDOMAIN` | ✅ — legitimate authoritative answer |
| `SERVFAIL` | ❌ — keep waiting |
| `REFUSED` | ❌ — keep waiting |
| `FORMERR` | ❌ — keep waiting |
| Network / timeout error | ❌ — keep waiting |

If all upstreams return errors, the last non-successful response is returned.

### Upstream health model

A background prober sends a lightweight query (`health.check.dnsd.local.` Type A, RD=0) to each upstream at `probe_interval`. The response time is stored in a rolling window of `sample_window` samples.

| Status | Condition |
|--------|-----------|
| **Healthy** | Avg RTT < `slow_above`, no recent probe errors |
| **Slow** | Avg RTT ≥ `slow_above` |
| **Failing** | Last `failing_after` consecutive probes all errored |

Probe notes:
- The probe query uses a private-use name — never a public cacheable name, to avoid polluting forwarder caches.
- Errors are not included in the RTT average (a 2s timeout would corrupt a sub-10ms rolling average).
- Probe transport matches forwarder transport — a DoT forwarder is always probed over DoT.
- One goroutine per forwarder, cancelled and restarted when config changes (no goroutine leaks).

---

## DNS filtering

The filter engine is a **reversed-label trie** — suffix matching runs in O(labels) time.

### How matching works

- The query name is split into labels and traversed from the TLD inward.
- A match on `doubleclick.net` will match `ads.doubleclick.net` (subdomain) but **not** `notdoubleclick.net` (no prefix collision).
- **Allowlist always beats blocklist**, regardless of which list loaded first.

### Block actions

| Action | DNS response |
|--------|-------------|
| `nxdomain` | NXDOMAIN — name does not exist |
| `nodata` | NODATA — no records |
| `sinkhole` | Configured sinkhole IPs (configurable IPv4/IPv6) |
| `refused` | REFUSED rcode |
| `custom_cname` | Redirect to specified hostname |

### List formats

| Format | Description |
|--------|-------------|
| `hosts` | `0.0.0.0 domain.com` or `127.0.0.1 domain.com` style |
| `domain-only` | One domain per line |
| `AdBlock` | `||domain.com^` filter syntax |
| `dnsmasq` | `address=/domain.com/0.0.0.0` style |
| `auto` | Auto-detected format |

---

## Response cache

The cache stores both positive responses (records) and negative responses (NXDOMAIN, NODATA per RFC 2308).

### Cache key

```
(qname-lowercased, qtype, qclass, DO-bit)
```

The DO bit is part of the key — DNSSEC-aware and unaware queries are cached separately.

**Never cached:** SERVFAIL, REFUSED.

---

## Dynamic DNS (RFC 2136)

homeDNS accepts DNS UPDATE messages. Authentication is per-zone:

| Mode | Trust anchor |
|------|-------------|
| `none` | No updates (default) |
| `ip_acl` | Source IP in allowed CIDRs |
| `tsig_required` | TSIG key required |
| `tsig_optional` | Either ACL or TSIG |

Supported TSIG algorithms: HMAC-MD5, SHA-1, SHA-256, SHA-512. See [Dynamic DNS](/operations/dynamic-dns/) for DHCP server setup.

<Aside type="note">
GSS-TSIG (RFC 3645, used by Microsoft DHCP in "secure-only" / Active Directory mode) is not supported in v1. Use `ip_acl` mode with a tight CIDR allowlist as a workaround.
</Aside>

---

## DNSSEC

DNSSEC validation stubs are present in v1. The `dnssec_validate` flag in `recursion` activates hook points but full DNSSEC chain validation is a v2 feature. Trust anchor management is exposed via the `/api/v1/dnssec/*` API and the DNSSEC page in the web admin.

---

## ACL and rate limiting

### ACL

Three CIDR lists in YAML:

- `acl.allow_query` — who may submit any DNS query
- `acl.allow_recurse` — who may trigger recursive resolution
- `acl.deny_query` — explicitly rejected sources (evaluated first)

All lists match against the client's IP address.

### Rate limiting

Per-source-IP token bucket. Queries exceeding the burst are dropped silently. Configure via `rate_limit.*` in YAML.
