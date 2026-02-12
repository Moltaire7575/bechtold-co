# Next steps (Cinematic Scholar MVP)

## 1) Push latest commit to GitHub
This workspace has new commits locally, but the agent environment cannot authenticate to GitHub.

From your GitHub Codespace / browser environment:
- `git pull`
- `git push`

Or just open the Codespace terminal and run:
```bash
git status
git log -1

git push
```

## 2) Supabase project
Create a new Supabase project (or use existing) and run:
- `supabase/schema.sql` in **Supabase → SQL Editor**

Then create Storage buckets:
- `thumbnails` (public read)
- (later) `videos` (private, signed URLs)

## 3) Cloudflare Pages environment variables
Set these in **Cloudflare Pages → Settings → Environment variables**:
- `PUBLIC_SUPABASE_URL`
- `PUBLIC_SUPABASE_ANON_KEY`

## 4) Wire the UI to real data
MVP plan:
- `/` homepage rows query `videos` by `pillar` + `is_featured`
- `/library` query `videos` with filters/search
- `/library/[slug]` query single video by `slug`

## 5) Admin MVP
- `/signin` via Supabase Auth
- `/admin` allowlist email -> set `profiles.is_admin = true`
- Admin can create/edit videos + upload thumbnail
