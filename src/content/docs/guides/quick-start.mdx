---
title: Quick Start
description: Build and run homeDNS locally in minutes — including the web admin, CLI, and a DNS smoke test.
---

import { Aside } from '@astrojs/starlight/components';

## Prerequisites

- **Go** — version specified in `go.mod`
- **Bun** — required for the `web-admin` frontend build
- **OpenSSL** — for local TLS cert generation (DoT/DoH testing)
- **Make** — build orchestration

Optional but recommended for auditing:

- `golangci-lint`, `govulncheck`, `semgrep`

## 1. Build

From the repo root:

```bash
make build
```

This does three things in order:

1. Builds the React `web-admin` SPA (`bun install && bun run build`)
2. Syncs the compiled assets into `internal/api/embedfs/`
3. Compiles `dnsd` and `dnsctl` → `bin/`

---

## 2. Run with example config

```bash
./bin/dnsd --config config.example.yaml
```

The daemon starts:

- Do53 listener (check `config.example.yaml` for the port — it may use a non-privileged port like `5353` in the example config)
- Management HTTP server at `127.0.0.1:8080`

---

## 3. Open the web admin

```bash
open http://127.0.0.1:8080/admin
```

The app shell is `/admin`. The main dashboard is at `/admin/dashboard`.

### SimpleSet — guided onboarding

First-time users can use **SimpleSet** (`/admin/simpleset`) for a short wizard that configures:

- DNS mode: forward-only or create an authoritative zone
- Upstream resolver (transport + address, with curated public resolver quick-picks)
- Optional malware blocklist

This is the fastest path to a working resolver without touching the YAML directly.

---

## 4. Verify DNS resolution

Point `dig` at the Do53 listener. Adjust the port if your config uses a non-standard one:

```bash
dig @127.0.0.1 -p 5353 example.com.
```

A successful response (`NOERROR` with answers from your upstream) confirms the resolver pipeline is live.

---

## 5. Try the CLI

```bash
# List configured zones
./bin/dnsctl zones list

# Check forwarder health
./bin/dnsctl health

# Launch the interactive TUI
./bin/dnsctl tui
```

All `dnsctl` commands talk to the management API at `127.0.0.1:8080` by default.

---

## 6. Generate a self-signed TLS cert (DoT/DoH testing)

Required only if you enable the DoT or DoH listeners:

```bash
mkdir -p certs
openssl ecparam -name secp384r1 -genkey -noout -out certs/server.key
openssl req -new -x509 -sha384 -key certs/server.key -out certs/server.crt -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

Update `config.example.yaml` to point `tls.cert_file` and `tls.key_file` at these paths, then enable the DoT or DoH listener.

Inspect the generated cert:

```bash
openssl x509 -in certs/server.crt -text -noout
```

---

## 7. Production build and install

For stripped, release-ready binaries:

```bash
GOFLAGS='-trimpath' LDFLAGS='-s -w' make build
```

Then follow one of the deployment paths in [Deployment](/operations/deployment/):

- **systemd** — recommended for single-host installs
- **Docker** — `deploy/Dockerfile`
- **Kubernetes** — `deploy/k8s/homedns.yaml`

---

<Aside type="tip">
If all queries return `SERVFAIL` on first boot, check that at least one forwarder is configured **or** `recursion.enabled: true` is set in your config. See [Runbook](/operations/runbook/) for the full troubleshooting table.
</Aside>
