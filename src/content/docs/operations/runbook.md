---
title: Runbook
description: Day-2 operational tasks for homeDNS in production.
---

## Health checks

```text
GET /api/v1/health
GET /api/v1/version
GET /api/v1/stats
```

If `/health` fails, restart the daemon and inspect logs.

## Common operator tasks

### Add a zone

```bash
dnsctl zones create example.com
dnsctl records add example.com 'www.example.com. 300 IN A 192.0.2.1'
dnsctl zones export example.com
```

### Add a blocklist

```bash
dnsctl filter add --name stevenblack \
  --url https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
  --format 1
dnsctl filter refresh
dnsctl filter test ads.doubleclick.net
```

### Add a conditional forwarder

```bash
dnsctl forwarders add --id corp --upstream 10.0.0.53:53 --strategy parallel
```

Supported strategies: `failover`, `round_robin`, `random`, `parallel`, `hedged`.

## Backup guidance

- Memory storage is ephemeral
- SQLite storage can be backed up from `data_dir/homedns.db` (WAL mode enabled)

## Frequent failures

- `SERVFAIL` everywhere: no forwarders and recursion disabled
- `403` on API: caller is outside `management.allow_cidrs`
- Filter always allows: list not loaded yet, run `dnsctl filter refresh`
- Restart loop under systemd: invalid config, run standalone with `--config` first
