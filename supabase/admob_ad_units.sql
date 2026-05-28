-- AdMob App ID + Ad Unit IDs — Supabase SQL Editor में चलाएँ।
-- ऐप runtime पर यहाँ से सभी unit IDs लेता है (test + production)।
-- नीचे Google sample (test) IDs हैं; live पर table में real IDs UPDATE करें।
--
-- ═══ Supabase update ke baad (ek baar terminal) ═══
--   dart run scripts/pull_admob_config_from_supabase.dart
--   flutter run   (hot restart se native App ID change nahi hota)
-- Yeh script: assets JSON + android/admob_app_ids.properties + iOS Info.plist sync karega.

create table if not exists public.admob_ad_units (
  id text primary key,
  placement text not null,
  ad_format text not null,
  platform text not null,
  ad_unit_id text not null,
  label_hi text,
  is_active boolean not null default true,
  sort_order int not null default 0,
  updated_at timestamptz not null default now(),
  constraint admob_ad_units_platform_check
    check (platform in ('android', 'ios')),
  constraint admob_ad_units_format_check
    check (ad_format in (
      'app_id',
      'banner',
      'interstitial',
      'rewarded',
      'native',
      'app_open'
    )),
  constraint admob_ad_units_unique_slot
    unique (placement, ad_format, platform)
);

create index if not exists admob_ad_units_active_idx
  on public.admob_ad_units (is_active, placement, ad_format, platform);

alter table public.admob_ad_units enable row level security;

drop policy if exists "admob_ad_units_public_read" on public.admob_ad_units;
create policy "admob_ad_units_public_read"
  on public.admob_ad_units
  for select
  to anon, authenticated
  using (is_active = true);

comment on table public.admob_ad_units is
  'AdMob — placement + format + platform पर ad unit / app id।';
comment on column public.admob_ad_units.placement is
  'app | deity_content | mandir | puja_exit | aarti_reward आदि';
comment on column public.admob_ad_units.ad_format is
  'app_id | banner | interstitial | rewarded | native | app_open';

-- ═══ App IDs (manifest / Info.plist के साथ मेल खाएँ) ═══
insert into public.admob_ad_units (
  id, placement, ad_format, platform, ad_unit_id, label_hi, sort_order
) values
  (
    'app_id_android',
    'app',
    'app_id',
    'android',
    'ca-app-pub-3940256099942544~3347511713',
    'AdMob App ID — Android (test)',
    1
  ),
  (
    'app_id_ios',
    'app',
    'app_id',
    'ios',
    'ca-app-pub-3940256099942544~1458002511',
    'AdMob App ID — iOS (test)',
    2
  )
on conflict (id) do update set
  ad_unit_id = excluded.ad_unit_id,
  label_hi = excluded.label_hi,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- ═══ Banner — पूजा / आरती देवता स्क्रीन (नीचे) ═══
insert into public.admob_ad_units (
  id, placement, ad_format, platform, ad_unit_id, label_hi, sort_order
) values
  (
    'deity_banner_android',
    'deity_content',
    'banner',
    'android',
    'ca-app-pub-3940256099942544/6300978111',
    'बैनर — देवता पूजा/आरती (Android test)',
    10
  ),
  (
    'deity_banner_ios',
    'deity_content',
    'banner',
    'ios',
    'ca-app-pub-3940256099942544/2934735716',
    'बैनर — देवता पूजा/आरती (iOS test)',
    11
  )
on conflict (id) do update set
  ad_unit_id = excluded.ad_unit_id,
  label_hi = excluded.label_hi,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- ═══ Interstitial — उदाहरण (बाद में UI जोड़ें) ═══
insert into public.admob_ad_units (
  id, placement, ad_format, platform, ad_unit_id, label_hi, sort_order
) values
  (
    'puja_exit_interstitial_android',
    'puja_exit',
    'interstitial',
    'android',
    'ca-app-pub-3940256099942544/1033173712',
    'इंटरस्टीशियल — पूजा बंद (Android test)',
    20
  ),
  (
    'puja_exit_interstitial_ios',
    'puja_exit',
    'interstitial',
    'ios',
    'ca-app-pub-3940256099942544/4411468910',
    'इंटरस्टीशियल — पूजा बंद (iOS test)',
    21
  )
on conflict (id) do update set
  ad_unit_id = excluded.ad_unit_id,
  label_hi = excluded.label_hi,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- ═══ Rewarded ═══
insert into public.admob_ad_units (
  id, placement, ad_format, platform, ad_unit_id, label_hi, sort_order
) values
  (
    'aarti_rewarded_android',
    'aarti_reward',
    'rewarded',
    'android',
    'ca-app-pub-3940256099942544/5224354917',
    'रिवॉर्डेड — आरती (Android test)',
    30
  ),
  (
    'aarti_rewarded_ios',
    'aarti_reward',
    'rewarded',
    'ios',
    'ca-app-pub-3940256099942544/1712485313',
    'रिवॉर्डेड — आरती (iOS test)',
    31
  )
on conflict (id) do update set
  ad_unit_id = excluded.ad_unit_id,
  label_hi = excluded.label_hi,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- ═══ Native (advanced) ═══
insert into public.admob_ad_units (
  id, placement, ad_format, platform, ad_unit_id, label_hi, sort_order
) values
  (
    'home_native_android',
    'home_feed',
    'native',
    'android',
    'ca-app-pub-3940256099942544/2247696110',
    'नेटिव — होम फीड (Android test)',
    40
  ),
  (
    'home_native_ios',
    'home_feed',
    'native',
    'ios',
    'ca-app-pub-3940256099942544/3986624511',
    'नेटिव — होम फीड (iOS test)',
    41
  )
on conflict (id) do update set
  ad_unit_id = excluded.ad_unit_id,
  label_hi = excluded.label_hi,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- ═══ App Open ═══
insert into public.admob_ad_units (
  id, placement, ad_format, platform, ad_unit_id, label_hi, sort_order
) values
  (
    'app_open_android',
    'app_launch',
    'app_open',
    'android',
    'ca-app-pub-3940256099942544/9257395921',
    'ऐप ओपन — लॉन्च (Android test)',
    50
  ),
  (
    'app_open_ios',
    'app_launch',
    'app_open',
    'ios',
    'ca-app-pub-3940256099942544/5575463023',
    'ऐप ओपन — लॉन्च (iOS test)',
    51
  )
on conflict (id) do update set
  ad_unit_id = excluded.ad_unit_id,
  label_hi = excluded.label_hi,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();
