// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://docs.homedns.app',
	integrations: [
		starlight({
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
						{ label: 'Overview', slug: 'index' },
						{ label: 'Quick Start', slug: 'guides/quick-start' },
						{ label: 'Configuration', slug: 'guides/configuration' },
					],
				},
				{
					label: 'Operations',
					items: [
						{ label: 'Runbook', slug: 'operations/runbook' },
						{ label: 'Deployment', slug: 'operations/deployment' },
						{ label: 'Dynamic DNS', slug: 'operations/dynamic-dns' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'Management API', slug: 'reference/management-api' },
						{ label: 'Security Model', slug: 'reference/security-model' },
						{ label: 'Release Checklist', slug: 'reference/release-checklist' },
					],
				},
			],
		}),
	],
});
