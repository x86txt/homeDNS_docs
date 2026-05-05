# homeDNS Docs

Documentation site for the [homeDNS](https://github.com/x86txt/homeDNS) project, built with Astro + Starlight.

## Local development

```bash
bun install
bun run dev
```

Or with pnpm:

```bash
pnpm install
pnpm dev
```

## Build

```bash
pnpm build
```

Alternative:

```bash
bun run build
```

## Cloudflare Pages deployment

- Framework preset: Astro
- Build command: `pnpm build` (or `bun run build`)
- Build output directory: `dist`
- Production branch: `main`

After the Pages project is live, add a Cloudflare DNS CNAME:

- Name: `docs`
- Target: your Pages hostname
- Zone: `homedns.app`

This serves docs at `docs.homedns.app`.
