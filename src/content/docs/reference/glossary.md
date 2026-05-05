---
title: Glossary
description: Key terms used throughout the homeDNS documentation.
---

| Term | Definition |
|------|-----------|
| **Authoritative zone** | A zone for which `dnsd` holds the official records and answers queries with `AA` (Authoritative Answer) set. |
| **Conditional forwarder** | A rule that says "for queries matching zone X, use this upstream chain and strategy." Multiple forwarders can co-exist for different zones. |
| **Do53** | Classic DNS over UDP and TCP on port 53. Plaintext — no transport encryption. |
| **DoH** | DNS over HTTPS (RFC 8484). Uses HTTP POST or GET with `application/dns-message` over port 443. Supports HTTP/1.1 and HTTP/2. |
| **DoH3** | DNS over HTTP/3 (RFC 9230). DoH semantics carried over QUIC-based HTTP/3. Roadmap item in v1. |
| **DoQ** | DNS over QUIC (RFC 9250). QUIC transport, port 853, ALPN `doq`. Roadmap item in v1. |
| **DoT** | DNS over TLS (RFC 7858). TCP with TLS, port 853, ALPN `dot`. Each message prefixed with a 2-byte length. |
| **Filter source** | A downloadable list of domain names to block (hosts, domain-only, AdBlock, dnsmasq formats). Maintained by the filter engine's trie. |
| **Forwarder strategy** | Controls how `dnsd` queries the upstream chain for a conditional forwarder: `failover`, `round_robin`, `random`, `parallel`, or `hedged`. |
| **GSS-TSIG** | Kerberos-based TSIG variant (RFC 3645) used by Microsoft DHCP in Active Directory "secure-only" mode. Not supported in v1. |
| **Hedged forwarding** | A forwarding strategy that fires the first upstream then fires the next after a delay based on observed latency — lower load amplification than full parallel with similar tail-latency benefits. |
| **NODATA** | A DNS response where the queried name exists but has no records of the requested type. Returns `NOERROR` with an empty answer section. |
| **NXDOMAIN** | A DNS response indicating the queried name does not exist. |
| **Parallel forwarding** | A forwarding strategy that races all configured upstreams simultaneously, accepts the first valid response, and cancels the remaining requests. |
| **Probe query** | A lightweight synthetic query (`health.check.dnsd.local.` Type A) sent periodically to each upstream to measure latency without polluting their caches. |
| **PTR record** | Pointer record — maps an IP address to a hostname, used for reverse DNS lookups. |
| **RR / Resource Record** | A single DNS record: name, TTL, class, type, and rdata (e.g. `www.example.com. 300 IN A 192.0.2.1`). |
| **Recursion** | The process of resolving a query by iteratively following delegations from the DNS root down to the authoritative server, when no local zone or cached answer exists. |
| **RFC 1035** | The original DNS specification (and zone file format). |
| **RFC 2136** | The DNS UPDATE standard. Defines the wire format for dynamic DNS updates from DHCP servers and `nsupdate`. |
| **RFC 2308** | Negative caching for DNS — defines how NXDOMAIN and NODATA responses should be cached. |
| **Reverse zone** | An authoritative zone in the `in-addr.arpa` (IPv4) or `ip6.arpa` (IPv6) namespace used for reverse DNS lookups. |
| **SimpleSet** | The guided onboarding wizard in the web admin (`/admin/simpleset`) that configures a minimal working resolver in three steps. |
| **SOA** | Start of Authority record. Contains the zone's primary NS, admin contact, serial, and TTL parameters. Auto-incremented on edits. |
| **SSE** | Server-Sent Events — a unidirectional HTTP streaming protocol used by homeDNS for live query logs, health updates, and stats (`text/event-stream`). |
| **Sinkhole** | A filter action that returns a configured IP address (e.g. `0.0.0.0`) for blocked queries instead of NXDOMAIN. Useful for capturing blocked traffic. |
| **TSIG** | Transaction Signature (RFC 2845). HMAC-based authentication for DNS UPDATE messages, ensuring only trusted clients can register or update records. |
| **WAL mode** | Write-Ahead Logging — SQLite mode that allows safe live backups by copying the database file while it is open and actively written to. |
| **Zone file** | A text file containing DNS resource records in RFC 1035 presentation format. Can be imported and exported by homeDNS. |
