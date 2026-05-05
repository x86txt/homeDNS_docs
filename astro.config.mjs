// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://docs.homedns.app',
	integrations: [
		starlight({
			disable404Route: true,
			title: 'homeDNS Docs',
			description: 'Documentation for the homeDNS modern multi-protocol DNS server.',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/x86txt/homeDNS' }],
			customCss: ['./src/styles/theme.css'],
			components: {
				Footer: './src/components/Footer.astro',
			},
			sidebar: [
				{
					label: 'Getting Started',
					items: [
						{ label: 'Overview',        slug: 'index' },
						{ label: 'Quick Start',     slug: 'guides/quick-start' },
						{ label: 'Configuration',   slug: 'guides/configuration' },
						{ label: 'Web Admin Guide', slug: 'guides/web-ui' },
					],
				},
				{
					label: 'Operations',
					items: [
						{ label: 'Runbook',      slug: 'operations/runbook' },
						{ label: 'Deployment',   slug: 'operations/deployment' },
						{ label: 'Dynamic DNS',  slug: 'operations/dynamic-dns' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'DNS Features',      slug: 'reference/dns-features' },
						{ label: 'Management API',    slug: 'reference/management-api' },
						{ label: 'CLI Reference',     slug: 'reference/cli' },
						{ label: 'Security Model',    slug: 'reference/security-model' },
						{ label: 'Release Checklist', slug: 'reference/release-checklist' },
						{ label: 'Glossary',          slug: 'reference/glossary' },
					],
				},
			],
		}),
	],
});
