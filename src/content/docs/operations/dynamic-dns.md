---
title: Dynamic DNS (RFC 2136)
description: Configure secure dynamic DNS updates from DHCP servers and nsupdate.
---

homeDNS supports RFC 2136 update messages for dynamic record registration.

## Update policy modes

| Mode | Trust anchor | Typical clients |
| --- | --- | --- |
| `ip_acl` | Source IP in allowed CIDRs | Microsoft DHCP non-secure mode |
| `tsig_required` | Valid TSIG key | ISC `dhcpd`, `nsupdate`, MS simple-TSIG |
| `tsig_optional` | Either ACL or TSIG | Mixed environments |
| `none` | Updates disabled | Default |

## Quick start

Enable policy on a zone:

```bash
dnsctl policy set --zone example.com --mode ip_acl \
  --cidrs 10.0.0.0/24,127.0.0.0/8
```

Or require TSIG:

```bash
dnsctl tsig add --name dhcp-update. --alg sha256 \
  --secret "$(openssl rand -base64 32)"
dnsctl policy set --zone example.com --mode tsig_required \
  --keys dhcp-update.
```

Validate with `nsupdate`:

```bash
nsupdate -y hmac-sha256:dhcp-update.:<base64-secret> <<EOF
server 127.0.0.1 53
zone example.com.
update add client01.example.com. 300 A 10.0.0.99
send
EOF
```

## Notes

- GSS-TSIG (AD secure-only flow) is not supported in v1
- Treat TSIG secrets as credentials and rotate regularly
- Pair TSIG with CIDR restrictions when possible
