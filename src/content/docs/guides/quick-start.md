---
title: Quick Start
description: Build and run homeDNS locally in minutes.
---

## Prerequisites

- Go (version in `go.mod`)
- Bun (for the embedded `web-admin` build)
- OpenSSL (for local TLS cert generation/testing)

## Build

```bash
make build
```

This compiles:

- `bin/dnsd`
- `bin/dnsctl`

## Run locally

```bash
./bin/dnsd --config config.example.yaml
```

In another terminal:

```bash
./bin/dnsctl zones list
./bin/dnsctl tui
```

Open the web UI:

```bash
open http://127.0.0.1:8080/admin
```

## Verify DNS responses

```bash
dig @127.0.0.1 -p 5353 example.com.
```

## Local TLS certificate (optional for DoT/DoH testing)

```bash
mkdir -p certs
openssl ecparam -name secp384r1 -genkey -noout -out certs/server.key
openssl req -new -x509 -sha384 -key certs/server.key -out certs/server.crt -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```
