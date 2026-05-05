---
title: Runbook
description: Day-2 operator guide for homeDNS — health checks, common tasks, failure recovery, upgrades, and observability.
---

import { Aside } from '@astrojs/starlight/components';

## Health checks

```text
GET /api/v1/health     → { "status": "ok" }
GET /api/v1/version    → { "version": "...", "buildTime": "...", "debug": false }
GET /api/v1/stats      → cache/filter/health snapshot
```

If `/health` returns non-200 or times out, restart the daemon (systemd auto-restarts on failure by default).

```bash
# systemd
journalctl -u homedns -n 100
systemctl restart homedns

# Check forwarder health via CLI
dnsctl health
```

---

## Recursion vs forwarding

Without at least one of these configured, all resolution for non-local zones fails with `SERVFAIL`:

| Option | How to enable |
|--------|---------------|
| Full recursive resolver | `recursion.enabled: true` in YAML |
| Static YAML forwarder | `forwarders.servers[...]` in YAML |
| API/UI conditional forwarder | **Forwarders** page or `dnsctl forwarders add` |

---

## Adding a zone

```bash
# Create zone and add records
dnsctl zones create example.com
dnsctl records add example.com 'www.example.com.  300 IN A 192.0.2.1'
dnsctl records add example.com 'mail.example.com. 300 IN A 192.0.2.2'

# Export as zone file
dnsctl zones export example.com
```

Or via the web admin: **Zones → New zone** (wizard mode creates SOA, NS, and optional A record in one flow).

---

## Adding a blocklist

```bash
dnsctl filter add --name stevenblack \
  --url https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
  --format 1
dnsctl filter refresh
dnsctl filter test ads.doubleclick.net
```

Supported list formats: `hosts`, `domain-only`, `AdBlock`, `dnsmasq`, `auto`. Or via the web admin: **Filter → Add source**.

---

## Adding a conditional forwarder

```bash
dnsctl forwarders add --id corp --upstream 10.0.0.53:53 --strategy parallel
```

Available strategies:

| Strategy | Behaviour |
|----------|-----------|
| `failover` | Try each upstream in order; fall back on error |
| `round_robin` | Rotate through upstreams |
| `random` | Pick randomly |
| `parallel` | Race all; first valid answer wins, cancel losers |
| `hedged` | Staggered race — fire next upstream after a delay derived from observed latency |

Health-aware: failing upstreams are skipped by all strategies.

---

## Config reload

File-watch reload is enabled by default. Overwrite the config file in place and homeDNS will pick up the new values. Reload can also be triggered from the web admin: **Server → Reload**.

---

## Backup and restore

### Memory storage

Ephemeral by design — treat as a runtime cache. Data does not survive restarts.

### SQLite storage

```bash
# Safe live backup (WAL mode)
cp data/homedns.db data/homedns.db.bak
```

Or download via API/web admin: **Backup** page → download blob.

Restore: upload a backup via **Backup → Restore** (supports dry-run) or replace the `.db` file while the daemon is stopped.

---

## Upgrading

1. Stop the daemon (`systemctl stop homedns`)
2. Replace `bin/dnsd` and `bin/dnsctl`
3. Start the daemon (`systemctl start homedns`)
4. Watch logs for schema migration messages

Schema migrations are forward-only. Downgrading after a migration requires a fresh database (restore from pre-upgrade backup).

---

## Troubleshooting table

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| All queries return `SERVFAIL` | No forwarders configured and recursion disabled | Add a forwarder or set `recursion.enabled: true` |
| Management API returns 403 | Caller IP outside `management.allow_cidrs` | Adjust CIDR list or call from allowed network |
| Filter `decide` always returns Allow | No list loaded yet (first refresh pending) | Run `dnsctl filter refresh` or wait for scheduler |
| High latency on `parallel` strategy | Slow upstream not yet classified as failing | Check `dnsctl health`; tune `forwarding.health.slow_above` |
| Restart loops in systemd | Invalid config syntax | Run `./bin/dnsd --config /etc/homedns/config.yaml` standalone and check stderr |
| `nsupdate` returns REFUSED | DDNS policy not configured or wrong mode/CIDRs/keys | `dnsctl policy get <zone>` and adjust |
| `nsupdate` returns NOTAUTH | Key name or secret mismatch | Re-add via `dnsctl tsig add` with correct algorithm |

---

## Observability

| Source | Detail |
|--------|--------|
| Structured logs | `logging.format: json` for production — pipe to your log aggregator |
| Live query log | `GET /api/v1/queries/stream` (SSE) or **Queries** page in web admin |
| Stats stream | `GET /api/v1/stats/stream` (SSE) — rolling QPS/cache/filter counters |
| Forwarder health | `GET /api/v1/forwarders/health/stream` (SSE) — health and latency updates |

Prometheus `/metrics` endpoint is on the roadmap; `GET /api/v1/stats` covers operational monitoring in v1.
