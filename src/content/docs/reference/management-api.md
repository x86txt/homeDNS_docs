---
title: Management API
description: Reference for the homeDNS management API surface.
---

The management API is served from `/api/v1/*` (default bind: `127.0.0.1:8080`).

It is the shared control surface used by:

- `web-admin` GUI
- `dnsctl` CLI/TUI
- operator automation scripts

## Authentication model

Requests are gated in this order:

1. CIDR allowlist (`management.allow_cidrs`)
2. Session cookie (`homedns_session`) or bearer token

Status codes:

- `401` missing/invalid credentials
- `403` authenticated but insufficient role
- `404` resource absent or hidden by feature gate
- `409` conflict (for example, zone already exists)
- `400` validation error

## Major endpoint groups

- `meta`: `/health`, `/version`
- `zones` and `records`: zone + RR lifecycle
- `forwarders`: upstream management and health stream
- `filter`, `cache`, `ddns`
- `queries` and `stats` SSE streams
- `config`, `server`, `backup`, `metrics`

## SSE channels

- `/forwarders/health/stream` (`snapshot`, `health`)
- `/queries/stream` (`query`)
- `/stats/stream` (`stats`)

## Wire-format notes

- Forwarding strategy and transport are serialized as strings
- TLS runtime objects are not exposed directly on the wire
- API-specific TLS knobs use explicit fields like `skip_tls_verify`
