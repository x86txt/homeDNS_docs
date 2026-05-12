# homeDNS Docs

Documentation site for the homeDNS project, built with Astro + Starlight.

- Docs source: <https://github.com/x86txt/homeDNS_docs>
- Project source: update this README and the site links when the public homeDNS repository URL is available.

## Local development

```bash
bun install
bun run dev
```

This repository is locked with `bun.lock`, and CI uses `bun install --frozen-lockfile`.
Other package managers can be used for local experiments, but Bun is the reproducible path.

Optional pnpm flow:

```bash
pnpm install
pnpm dev
```

## Build

```bash
bun run build
```

Alternative with pnpm:

```bash
pnpm build
```

## Cloudflare Pages deployment

- Framework preset: Astro
- Build command: `bun run build` (or `pnpm build`)
- Build output directory: `dist`
- Production branch: `main`

After the Pages project is live, add a Cloudflare DNS CNAME:

- Name: `docs`
- Target: your Pages hostname
- Zone: `homedns.app`

This serves docs at `docs.homedns.app`.
