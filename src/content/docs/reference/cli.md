---
title: CLI Reference (dnsctl)
description: Complete command reference for dnsctl — the homeDNS command-line client and interactive TUI.
---

`dnsctl` is the command-line client for homeDNS. It communicates with the `dnsd` management API at `/api/v1` (default: `http://127.0.0.1:8080`).

```bash
./bin/dnsctl [--server <url>] <command> [subcommand] [flags]
```

All commands use the HTTP client in `cmd/dnsctl/internal/cli/client.go`.

---

## `zones`

Manage authoritative DNS zones.

```bash
# List all zones
dnsctl zones list

# Create a new zone
dnsctl zones create example.com

# Delete a zone
dnsctl zones delete example.com

# Export zone as RFC 1035 zone file (stdout)
dnsctl zones export example.com
```

---

## `records`

Manage individual resource records within a zone. Records are specified in **zone-file presentation format**.

```bash
# List all records in a zone
dnsctl records list example.com

# Add a record
dnsctl records add example.com 'www.example.com.  300 IN A 192.0.2.1'
dnsctl records add example.com 'mail.example.com. 300 IN MX 10 mail.example.com.'
dnsctl records add example.com 'example.com.      300 IN TXT "v=spf1 -all"'

# Delete a record (zone-file format)
dnsctl records delete example.com 'www.example.com. 300 IN A 192.0.2.1'
```

Supported record types: A, AAAA, CNAME, MX, TXT, SRV, NS, SOA, PTR, CAA.

---

## `forwarders`

Manage conditional forwarders.

```bash
# List all forwarders
dnsctl forwarders list

# Add a conditional forwarder
dnsctl forwarders add \
  --id     corp-internal \
  --zone   corp.internal \
  --upstream 10.0.0.53:53 \
  --strategy parallel

# Delete a forwarder
dnsctl forwarders delete corp-internal
```

Strategy options: `failover`, `round_robin`, `random`, `parallel`, `hedged`.

---

## `filter`

Manage DNS blocklist/allowlist sources and policy.

```bash
# Add a filter source
dnsctl filter add \
  --name stevenblack \
  --url  https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
  --format 1

# List sources
dnsctl filter list

# Force refresh all sources
dnsctl filter refresh

# Force refresh a specific source
dnsctl filter refresh --id stevenblack

# Test a domain name against the current filter state
dnsctl filter test ads.doubleclick.net
dnsctl filter test allowed-domain.com
```

Format values: `1` = hosts, `2` = domain-only, `3` = AdBlock, `4` = dnsmasq, `0` = auto-detect.

---

## `cache`

Inspect and control the response cache.

```bash
# Show cache statistics
dnsctl cache stats

# Flush the entire cache
dnsctl cache flush
```

---

## `health`

Snapshot the current health status of all configured forwarders.

```bash
dnsctl health
```

Output shows each upstream's status (healthy / slow / failing), current RTT average, and last-checked timestamp.

---

## `query log`

Tail or retrieve the recent DNS query log.

```bash
# Show recent queries
dnsctl query log

# Live tail (SSE stream)
dnsctl query log --follow
```

---

## `tsig`

Manage TSIG keys for DDNS authentication.

```bash
# Add a TSIG key
dnsctl tsig add \
  --name dhcp-update. \
  --alg  sha256 \
  --secret "$(openssl rand -base64 32)"

# List TSIG keys
dnsctl tsig list

# Delete a TSIG key
dnsctl tsig delete dhcp-update.
```

---

## `policy`

Manage per-zone DDNS update policies.

```bash
# Set policy (IP ACL mode)
dnsctl policy set \
  --zone  example.com \
  --mode  ip_acl \
  --cidrs 10.0.0.0/24,127.0.0.0/8

# Set policy (TSIG mode)
dnsctl policy set \
  --zone example.com \
  --mode tsig_required \
  --keys dhcp-update.

# Get current policy for a zone
dnsctl policy get example.com
```

Modes: `none`, `ip_acl`, `tsig_required`, `tsig_optional`.

---

## `tui`

Launch the full-screen interactive TUI. Provides the same operations as the web admin in a terminal-native interface.

```bash
dnsctl tui

# Beta TUI (if available in your build)
dnsctl tui-beta
```

Navigate with arrow keys; press `?` for help within the TUI.
