---
title: Deployment
description: Deploy homeDNS with systemd, Docker, or Kubernetes.
---

## Docker

```bash
docker build -f deploy/Dockerfile -t homedns:dev .
docker run --rm -p 5353:53/udp -p 8080:8080 \
  -v "$PWD/config.example.yaml:/app/config.yaml" \
  homedns:dev
```

The container is non-root by default. For low ports, use `CAP_NET_BIND_SERVICE` or host-level port mapping.

## systemd

```bash
sudo install -d /etc/homedns /var/lib/homedns
sudo install -m 0644 deploy/systemd/homedns.service /etc/systemd/system/homedns.service
sudo install -m 0644 config.example.yaml /etc/homedns/config.yaml
sudo install -m 0755 ./bin/dnsd /usr/local/bin/dnsd
sudo install -m 0755 ./bin/dnsctl /usr/local/bin/dnsctl
sudo useradd --system --no-create-home --shell /usr/sbin/nologin homedns || true
sudo systemctl daemon-reload
sudo systemctl enable --now homedns
```

## Kubernetes

```bash
kubectl apply -f deploy/k8s/homedns.yaml
kubectl -n homedns get pods,svc
```

Tune `Service` type, config, and `NetworkPolicy` for your environment.

## Docs site deployment (Cloudflare Pages)

For this docs repository:

- Build command: `bun run build` (or `pnpm build`)
- Output directory: `dist`
- Production branch: `main`

After deployment, create a DNS CNAME in Cloudflare:

- Name: `docs`
- Target: your Cloudflare Pages hostname
- Zone: `homedns.app`

This maps docs to `docs.homedns.app`.
