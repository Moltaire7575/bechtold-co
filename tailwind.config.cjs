/** @type {import('tailwindcss').Config} */
module.exports = {
	content: [
		'./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}',
	],
	theme: {
		extend: {
			colors: {
				bg: '#0B0D10',
				panel: '#151922',
				text: {
					DEFAULT: '#F2F2F2',
					muted: '#9BA3AF',
				},
				accent: {
					gold: '#C6A75E',
					cyan: '#2FA8C6',
				},
			},
			fontFamily: {
				sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
				display: ['Space Grotesk', 'Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
			},
			boxShadow: {
				cinematic: '0 12px 40px rgba(0,0,0,0.55)',
			},
		},
	},
	plugins: [],
};
