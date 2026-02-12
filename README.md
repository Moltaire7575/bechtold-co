# bechtold.co — Cinematic Scholar (Astro + Cloudflare Pages)

**Goal:** a premium, MasterClass-inspired, cinematic dark theme with a horizontal “streaming platform” browsing experience.

This repo keeps the original Astro + Cloudflare Pages approach, but implements the “cinematic streaming UI” and starts the **Supabase video library database early** to support pipelines.

## Routes (MVP)
- `/` — homepage with hero + horizontal rows
- `/library` — library grid (filters/search UI stub; will be wired to Supabase)
- `/library/[slug]` — video detail (embedded player URL MVP)
- `/signin` — Supabase Auth placeholder

## Stack
- Astro
- Tailwind CSS
- Supabase (Postgres + Auth + Storage)

## Supabase: required environment variables
Set these in local `.env` and in Cloudflare Pages environment variables:
- `PUBLIC_SUPABASE_URL`
- `PUBLIC_SUPABASE_ANON_KEY`

## Supabase schema
MVP schema:
- `supabase/schema.sql`

Run it in **Supabase → SQL Editor**.

## Dev
```bash
npm install
npm run dev
```

## Deploy
Cloudflare Pages:
- Build command: `npm run build`
- Output dir: `dist`
