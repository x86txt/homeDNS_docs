---
title: Security Model
description: Trust boundaries and controls in homeDNS v1.
---

homeDNS v1 uses a layered security model across DNS ingress, resolver logic, and management APIs.

## Trust boundaries

- DNS clients reach UDP/TCP/TLS/HTTPS listeners
- Resolver pipeline applies ACL, rate limiting, filter, cache, and forwarding logic
- Management operations are separately gated by network location and credentials

## DNS data-plane controls

- Per-listener bind control and graceful shutdown
- Query and recursion ACLs (`acl.allow_query`, `acl.allow_recurse`, `acl.deny_query`)
- Per-source rate limiting
- Query-budget and timeout limits in recursion
- DO-bit-safe cache keys and RFC 2308 negative caching
- Upstream response validation (transaction ID + question matching)
- Fast cancellation of losing upstreams in race strategies

## Management-plane controls

Defaults:

- Bind address: `127.0.0.1:8080`
- Allow CIDRs: loopback only
- Panic recovery middleware enabled

For exposure outside trusted networks, place an authenticating reverse proxy in front (mTLS, OIDC, or equivalent) and enforce strict CIDR policy.

## Build-time and release controls

The release checklist tracks the expected gates for source releases:

- `go vet`
- `go test -race`
- `golangci-lint`
- `semgrep p/owasp-top-ten`
- `govulncheck`
- resolver fuzz smoke tests

See [Release Checklist](/reference/release-checklist/) for the full pre-tag review list.
