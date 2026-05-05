---
title: Release Checklist
description: Production gates for a homeDNS release.
---

Use this checklist before tagging releases.

## Build and correctness

- `go build ./...`
- `go vet ./...`
- `go test -race -count=1 ./...`
- `golangci-lint run ./...`
- resolver fuzz smoke run

## Security gates

- `semgrep --config p/owasp-top-ten`
- `govulncheck ./...`
- path traversal protections validated
- hardened container security context validated

## Functional gates

- daemon boots from default config
- `/api/v1/health` returns 200
- zone, forwarder, and filter flows work through API + CLI + GUI
- recursion and caching benchmarks remain within target

## Documentation gates

- README is current
- runbook is current
- deployment guide is current
- security model reflects current controls
- sample configuration is current

## Known v1 limitations

- DoQ and DoH3 are roadmap items
- full DNSSEC validation/signing not in v1
- management-plane auth options are still evolving
- HA replication is out of scope for v1
