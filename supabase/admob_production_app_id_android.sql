-- Run in Supabase → SQL Editor
-- Production AdMob IDs for com.servecreative.bhakti_sadhana (Android)

UPDATE public.admob_ad_units
SET
  ad_unit_id = 'ca-app-pub-6827778613476055~1299323152',
  label_hi = 'AdMob App ID — Android (production)',
  updated_at = now()
WHERE id = 'app_id_android';

UPDATE public.admob_ad_units
SET
  ad_unit_id = 'ca-app-pub-6827778613476055/6165167256',
  label_hi = 'बैनर — देवता पूजा/आरती (Android production)',
  updated_at = now()
WHERE id = 'deity_banner_android';

-- Verify:
-- SELECT id, ad_unit_id, label_hi FROM public.admob_ad_units
-- WHERE id IN ('app_id_android', 'deity_banner_android');
