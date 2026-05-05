---
title: Configuration
description: Configure listeners, forwarding, filtering, ACLs, and management access.
---

homeDNS loads YAML configuration from `--config`.

## Core sections

- `server`: instance name and data directory
- `listeners`: Do53/DoT/DoH listener bindings
- `tls`: cert and key files for encrypted transports
- `recursion`: recursion safety limits
- `forwarding` and `forwarders`: strategy and upstream settings
- `filter`: block/allow behavior
- `acl`: query and recursion CIDR rules
- `management`: API bind and allowed CIDRs

## Example forwarders

```yaml
forwarders:
  contact_method: lowest_latency
  servers:
    - id: cloudflare-dot
      protocol: dot
      address: "1.1.1.1:853"
      dnssec: true
      timeout: 2s
      skip_tls_verify: false
    - id: cloudflare-doh
      protocol: doh
      address: "https://1.1.1.1/dns-query"
      dnssec: true
      timeout: 3s
```

`contact_method` options:

- `sequential`
- `parallel_first`
- `lowest_latency`

## Security defaults

- Management API binds to `127.0.0.1:8080`
- `management.allow_cidrs` defaults to loopback networks
- Query/recursion access is ACL-gated
- Rate limiting is enabled by default

For production hardening, review the [Security Model](/reference/security-model/).
