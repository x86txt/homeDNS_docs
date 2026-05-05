---
title: Web Admin Guide
description: Page-by-page guide to the homeDNS embedded web admin at /admin.
---

import { Aside } from '@astrojs/starlight/components';

The homeDNS web admin is a React SPA embedded in `dnsd` and served from the management listener. Access it at:

```
http://<management-bind>/admin
```

Default: `http://127.0.0.1:8080/admin`

The app uses light/dark/system themes, Geist fonts, and a tree-style left sidebar with live health indicators.

---

## SimpleSet

**Route:** `/admin/simpleset`

A short onboarding wizard for new deployments. Configures the minimum viable resolver in three steps:

1. **DNS mode** — forward-only (recommended for most home/office deployments) or create a local authoritative zone.
2. **Upstream resolver** — choose transport (`Do53`, `DoT`, `DoH`) and address, with curated quick-picks from a bundled public resolver list (Cloudflare, Quad9, NextDNS, etc.).
3. **Optional blocklist** — one-click malware/ad blocking using a popular hosts list.

Use SimpleSet first, then refine with the advanced pages as needed.

---

## Dashboard

**Route:** `/admin/dashboard`

High-level status overview:

- Resolver health and active upstreams
- QPS/cache hit rate trend
- Recent query log sample
- Active filter decisions

---

## Zones

**Route:** `/admin/zones`, `/admin/zones/:zone`

### Zone list

Shows all authoritative zones with record count and status. Controls:

- **New zone** (wizard) — create a zone with SOA, NS records, and an optional A record in one flow.
- **Import** — drag-and-drop or paste an RFC 1035 zone file.

### Zone detail

- Full record table with inline editing for common edits.
- Record types supported: A, AAAA, CNAME, MX, TXT, SRV, NS, SOA, PTR, CAA.
- **Add record** — accepts zone-file presentation format.
- **Delete record** — with SOA serial auto-increment on change.
- **Export** — downloads the zone as a standards-compliant zone file.

<Aside type="note">
The SOA serial increment button calls a dedicated API endpoint. Verify it exists in your running version before documenting in your own workflows.
</Aside>

---

## Forwarders

**Route:** `/admin/forwarders`

Conditional forwarders define which upstream chain handles queries for a given zone.

### Per-forwarder configuration

| Field | Notes |
|-------|-------|
| **Match zone** | Queries for this zone (and sub-zones) are forwarded to this entry |
| **Strategy** | `failover`, `round_robin`, `random`, `parallel`, `hedged` |
| **Upstream chain** | One or more upstreams, each with: transport, address, timeout, TLS options, DNSSEC flag |
| **Reorder** | Drag-and-drop to change priority order within the chain |

### Health display

Each upstream shows a live health badge:

- **Healthy** (avg RTT below threshold, no recent errors)
- **Slow** (RTT above `slow_above`)
- **Failing** (last N probes all failed)

Latency sparklines update via the **SSE health stream** (`/api/v1/forwarders/health/stream`) — no polling.

### Public resolver presets

The **preset picker** surfaces curated entries from `web-admin/src/data/public-resolvers.json` with transport and address pre-filled. A tooltip shows resolver properties and links to the provider's privacy policy.

A warning appears when using `parallel` strategy with more than four upstreams ("This will multiply egress query volume by Nx").

---

## Filter

**Route:** `/admin/filter`

Pi-hole / AdGuard Home–style DNS filtering.

### Filter sources

Each source is a downloadable list:

| Setting | Options |
|---------|---------|
| **URL** | Any HTTPS URL serving a supported format |
| **Format** | `hosts`, `domain-only`, `AdBlock`, `dnsmasq`, `auto` |
| **Refresh interval** | Override or use the global default |

Actions: add, delete, force refresh per-source.

### Policy

Global block action applied to matched names:

- `nxdomain` — query name does not exist
- `nodata` — name exists but no records
- `sinkhole` — return configured sinkhole IPs
- `refused` — return REFUSED rcode
- `custom_cname` — redirect to a specified hostname

Allowlist entries always override the blocklist regardless of load order.

### Test decision

Type a domain name into the **Test domain** panel to see the engine's real-time decision: `block` (with matching list), `allow` (explicit allowlist entry), or `pass` (not matched).

---

## Cache

**Route:** `/admin/cache`

- **Stats** — current cache size, hit/miss counters, positive vs negative cached entries.
- **Flush** — clears all cached records immediately.

---

## DDNS

**Route:** `/admin/ddns`

Manages RFC 2136 dynamic DNS update permissions. Two sub-sections:

### TSIG keys

Create and delete TSIG keys (HMAC-MD5, SHA-1, SHA-256, SHA-512) used to authenticate update messages from DHCP servers or `nsupdate`.

### Update policies

Per-zone policy controlling who may submit updates:

| Mode | Trust anchor |
|------|-------------|
| `none` | No updates accepted (default) |
| `ip_acl` | Source IP in allowed CIDRs |
| `tsig_required` | Valid TSIG key required |
| `tsig_optional` | Either ACL or TSIG accepted |

See [Dynamic DNS](/operations/dynamic-dns/) for DHCP server integration.

---

## Queries

**Route:** `/admin/queries`

Live and recent query log. The table updates in real time via the SSE stream at `/api/v1/queries/stream`. Columns include: timestamp, client IP, query name, type, rcode, latency, and filter decision.

---

## DNSSEC

**Route:** `/admin/dnssec`

Manages trust anchors and shows DNSSEC validator status. Backed by the `/api/v1/dnssec/*` API endpoints — verify implementation in your running version.

---

## ACL

**Route:** `/admin/acl`

Web interface for viewing and updating the DNS-side ACL configuration (`allow_query`, `allow_recurse`, `deny_query`). Backed by `/api/v1/acl`.

---

## Users

**Route:** `/admin/users`

User, role, and credential management. Three built-in roles:

| Role | Access |
|------|--------|
| **admin** | Full access, including user management |
| **operator** | All DNS and config operations; no user management |
| **viewer** | Read-only access |

### Actions

- Create/delete users and assign roles
- Reset passwords
- Issue API tokens (for `dnsctl` and automation scripts)
- List and revoke active sessions

---

## Config

**Route:** `/admin/config`

Two views:

- **Effective config** — the merged runtime config including all applied overrides (`GET /api/v1/config/effective`).
- **File config** — raw on-disk YAML (`GET /api/v1/config/file`).

Use these to confirm hot reload picked up your changes.

---

## Backup

**Route:** `/admin/backup`

- **Download** — exports a backup blob of all persistent data.
- **Restore** — upload a backup file; supports **dry-run** mode to validate without applying.

---

## Server

**Route:** `/admin/server`

- **Listeners** — shows active listener bindings and their state.
- **Reload** — triggers a config reload (`POST /api/v1/server/reload`).
- **Probe upstream** — manually fire a health probe for a specific forwarder (`POST /api/v1/server/probe/{id}`).
