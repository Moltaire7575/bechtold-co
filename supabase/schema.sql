-- bechtold.co — Cinematic Scholar
-- Supabase Postgres schema (MVP)
--
-- Goal: video library database built early so ingestion/pipelines have a stable target.
-- Notes:
-- - Use Supabase Auth for users.
-- - RLS policies are included as a sane starting point; tighten as needed.
-- - This file is intended to be run in Supabase SQL Editor.

-- Extensions
create extension if not exists pgcrypto;

-- Enums (optional; using text keeps it flexible early)
-- You can convert pillar/format to enums later.

-- Profiles
create table if not exists public.profiles (
	id uuid primary key references auth.users(id) on delete cascade,
	email text,
	is_admin boolean not null default false,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

-- Videos
create table if not exists public.videos (
	id uuid primary key default gen_random_uuid(),
	slug text not null unique,
	title text not null,
	description text not null default '',
	pillar text not null,
	subpillar text,
	format text not null,
	duration_seconds int not null default 0,
	difficulty int not null default 1 check (difficulty between 1 and 5),
	equipment text[] not null default '{}',
	goals text[] not null default '{}',
	thumbnail_url text,
	video_url text,
	is_featured boolean not null default false,
	published_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create index if not exists videos_pillar_idx on public.videos(pillar);
create index if not exists videos_published_at_idx on public.videos(published_at desc);
create index if not exists videos_is_featured_idx on public.videos(is_featured);

-- Tags
create table if not exists public.tags (
	id uuid primary key default gen_random_uuid(),
	name text not null,
	slug text not null unique,
	created_at timestamptz not null default now()
);

-- Video tags join
create table if not exists public.video_tags (
	video_id uuid not null references public.videos(id) on delete cascade,
	tag_id uuid not null references public.tags(id) on delete cascade,
	primary key (video_id, tag_id)
);

create index if not exists video_tags_tag_id_idx on public.video_tags(tag_id);

-- Series
create table if not exists public.series (
	id uuid primary key default gen_random_uuid(),
	title text not null,
	slug text not null unique,
	description text not null default '',
	hero_image text,
	created_at timestamptz not null default now()
);

-- Series videos join with ordering
create table if not exists public.series_videos (
	series_id uuid not null references public.series(id) on delete cascade,
	video_id uuid not null references public.videos(id) on delete cascade,
	sort_order int not null default 0,
	primary key (series_id, video_id)
);

create index if not exists series_videos_series_id_idx on public.series_videos(series_id);

-- User progress
create table if not exists public.user_video_progress (
	user_id uuid not null references auth.users(id) on delete cascade,
	video_id uuid not null references public.videos(id) on delete cascade,
	last_position_seconds int not null default 0,
	completed_at timestamptz,
	updated_at timestamptz not null default now(),
	primary key (user_id, video_id)
);

create index if not exists user_video_progress_user_id_idx on public.user_video_progress(user_id);

-- Playlists
create table if not exists public.playlists (
	id uuid primary key default gen_random_uuid(),
	user_id uuid not null references auth.users(id) on delete cascade,
	title text not null,
	created_at timestamptz not null default now()
);

create index if not exists playlists_user_id_idx on public.playlists(user_id);

create table if not exists public.playlist_items (
	playlist_id uuid not null references public.playlists(id) on delete cascade,
	video_id uuid not null references public.videos(id) on delete cascade,
	sort_order int not null default 0,
	added_at timestamptz not null default now(),
	primary key (playlist_id, video_id)
);

-- User notes (optional MVP)
create table if not exists public.user_video_notes (
	user_id uuid not null references auth.users(id) on delete cascade,
	video_id uuid not null references public.videos(id) on delete cascade,
	notes text not null default '',
	updated_at timestamptz not null default now(),
	primary key (user_id, video_id)
);

-- Trigger: update updated_at
create or replace function public.set_updated_at() returns trigger as $$
begin
	new.updated_at = now();
	return new;
end;
$$ language plpgsql;

create trigger videos_set_updated_at
before update on public.videos
for each row execute function public.set_updated_at();

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- RLS
alter table public.profiles enable row level security;
alter table public.videos enable row level security;
alter table public.tags enable row level security;
alter table public.video_tags enable row level security;
alter table public.series enable row level security;
alter table public.series_videos enable row level security;
alter table public.user_video_progress enable row level security;
alter table public.playlists enable row level security;
alter table public.playlist_items enable row level security;
alter table public.user_video_notes enable row level security;

-- Policies
-- Public read: published videos/taxonomy
create policy "videos_public_read_published"
on public.videos for select
using (published_at is not null and published_at <= now());

create policy "tags_public_read" on public.tags for select using (true);
create policy "video_tags_public_read" on public.video_tags for select using (true);
create policy "series_public_read" on public.series for select using (true);
create policy "series_videos_public_read" on public.series_videos for select using (true);

-- Admin write (profiles.is_admin)
create or replace function public.is_admin() returns boolean as $$
	select exists (
		select 1
		from public.profiles p
		where p.id = auth.uid() and p.is_admin = true
	);
$$ language sql stable;

create policy "videos_admin_write" on public.videos
for all
using (public.is_admin())
with check (public.is_admin());

create policy "tags_admin_write" on public.tags
for all
using (public.is_admin())
with check (public.is_admin());

create policy "video_tags_admin_write" on public.video_tags
for all
using (public.is_admin())
with check (public.is_admin());

create policy "series_admin_write" on public.series
for all
using (public.is_admin())
with check (public.is_admin());

create policy "series_videos_admin_write" on public.series_videos
for all
using (public.is_admin())
with check (public.is_admin());

-- User-owned tables
create policy "profiles_self_read" on public.profiles
for select using (auth.uid() = id);

create policy "profiles_self_upsert" on public.profiles
for insert with check (auth.uid() = id);

create policy "profiles_self_update" on public.profiles
for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "progress_self" on public.user_video_progress
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "playlists_self" on public.playlists
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "playlist_items_self" on public.playlist_items
for all using (
	exists (select 1 from public.playlists p where p.id = playlist_id and p.user_id = auth.uid())
) with check (
	exists (select 1 from public.playlists p where p.id = playlist_id and p.user_id = auth.uid())
);

create policy "notes_self" on public.user_video_notes
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Seed guidance (run separately)
-- Insert a few tags/videos to validate UI quickly.
