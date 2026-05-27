-- लाइव दर्शन मंदिर सूची — Supabase SQL Editor में चलाएँ।
-- Handle बदलने पर यहाँ UPDATE करें; ऐप अगली बार fetch पर नया पकड़ेगा।

create table if not exists public.live_darshan_temples (
  id text primary key,
  name_hi text not null,
  location_hi text not null,
  deity_hi text not null,
  youtube_handle text,
  youtube_channel_id text,
  source_hi text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  updated_at timestamptz not null default now(),
  constraint live_darshan_youtube_source check (
    nullif(trim(coalesce(youtube_handle, '')), '') is not null
    or nullif(trim(coalesce(youtube_channel_id, '')), '') is not null
  )
);

create index if not exists live_darshan_temples_active_sort_idx
  on public.live_darshan_temples (is_active, sort_order);

alter table public.live_darshan_temples enable row level security;

drop policy if exists "live_darshan_public_read" on public.live_darshan_temples;
create policy "live_darshan_public_read"
  on public.live_darshan_temples
  for select
  to anon, authenticated
  using (is_active = true);

-- पहली बार / रीसीड (id conflict पर update)
insert into public.live_darshan_temples (
  id, name_hi, location_hi, deity_hi, youtube_handle, youtube_channel_id, source_hi, sort_order
) values
  (
    'kashi_vishwanath',
    'श्री काशी विश्वनाथ',
    'वाराणसी, उत्तर प्रदेश',
    'भगवान शिव',
    'AwadhMala',
    null,
    'लाइव — @AwadhMala',
    10
  ),
  (
    'mahakaleshwar',
    'श्री महाकालेश्वर',
    'उज्जैन, मध्य प्रदेश',
    'भगवान शिव (ज्योतिर्लिंग)',
    'DDAstro',
    null,
    'महाकालेश्वर — @DDAstro',
    20
  ),
  (
    'somnath',
    'श्री सोमनाथ मंदिर',
    'प्रभास पाटन, गुजरात',
    'भगवान शिव (प्रथम ज्योतिर्लिंग)',
    'SomnathTempleOfficialChannel',
    null,
    'सोमनाथ — @SomnathTempleOfficialChannel',
    30
  ),
  (
    'matanamadh',
    'श्री मातानामढ़ (आशापुरा माता)',
    'लखपत, कच्छ, गुजरात',
    'माता आशापुरा',
    'Matanamadh',
    null,
    'मातानामढ़ — @Matanamadh',
    35
  ),
  (
    'tirupati_svbc',
    'श्री वेंकटेश्वर (तिरुमला)',
    'तिरुपति, आंध्र प्रदेश',
    'भगवान वेंकटेश्वर',
    null,
    'UCTboTRX74UydvU_cBdm_cCQ',
    'TTD — SVBC लाइव',
    40
  ),
  (
    'shirdi_sai',
    'शिरडी साईं बाबा',
    'शिरडी, महाराष्ट्र',
    'साईं बाबा',
    'Sai_Bhakti_Original',
    null,
    'साईं भक्ति — @Sai_Bhakti_Original',
    50
  )
on conflict (id) do update set
  name_hi = excluded.name_hi,
  location_hi = excluded.location_hi,
  deity_hi = excluded.deity_hi,
  youtube_handle = excluded.youtube_handle,
  youtube_channel_id = excluded.youtube_channel_id,
  source_hi = excluded.source_hi,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

-- उदाहरण: handle बदलना
-- update public.live_darshan_temples
-- set youtube_handle = 'NayaHandle', updated_at = now()
-- where id = 'somnath';
