## Learned User Preferences

- Dark mode is first-class, not a toggle afterthought — design and test dark first
- Design reference for the docs site is https://www.openfang.sh/docs (layout/structure/rhythm only; replace orange accent with homeDNS green)
- Source-of-truth for design tokens is `../homeDNS/web-admin/src/index.css` and `../homeDNS/web-admin/src/layouts/AdminLayout.tsx`
- Never use Starlight's `template: splash` on the index page — it forces the wrong layout
- Don't use `position: absolute` for numbered index labels inside grid cards (causes text overlap)
- Footer spacing must use `margin-top: 2.5rem`, not `margin-top: auto` (auto pushes footer to touch content)
- Remove duplicate `border-bottom` from `.header` — Starlight already provides it via `PageFrame.astro`; two declarations stack visually
- Reset Starlight's default markdown sibling margins inside custom grids with `margin-top: 0 !important`
- Right-rail column width must match left sidebar width (both `--sl-sidebar-width: 15rem`)
- Use ItsHover icons throughout the site wherever icon UI is needed

## Learned Workspace Facts

- Project: homeDNS DNS server docs site; app source lives at `../homeDNS` (sibling repo)
- GitHub: `x86txt/homeDNS_docs` — `https://github.com/x86txt/homeDNS_docs`
- Docs URL: `https://docs.homedns.app/` | Main product: `https://homedns.app/`
- Package manager: `bun` — build command is `bun run build`, output dir `dist/`
- Framework: Astro + Starlight (`@astrojs/starlight ^0.38.4`)
- Fonts: `@fontsource-variable/geist` + `@fontsource-variable/geist-mono` (installed as npm deps)
- Sans stack: `"Geist Variable", "Geist", ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif`
- Mono stack: `"Geist Mono Variable", "Geist Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace`
- Brand green light: `#0C8C5E` | dark: `#18E299` | Dark shell: `#080706` | Dark panel: `#0F0E0E` | Dark card: `#1F1D1C` | Dark border: `#2D2A28`
- Deployment: Cloudflare Pages (free tier), GitHub-integrated CI (auto-rebuild on push to `main`)
- Custom domain `docs.homedns.app` is a CNAME in Cloudflare DNS pointing to the Pages project
- Cloudflare Pages project name: `homedns-docs`; setup script at `scripts/setup-cloudflare-pages.sh`
- Admin sidebar density: `--sl-sidebar-width: 15rem` (w-60) | header: `--sl-nav-height: 3.5rem` (h-14)
