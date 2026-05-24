-- Supabase Dashboard → SQL Editor में चलाएँ (एक बार)।
-- Bucket "aartis" पहले Storage UI से बनाएँ (Public bucket ON)।

-- Public read for aarti MP3s
CREATE POLICY "Public read aartis"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'aartis');

-- Uploads: केवल Dashboard / service role (app se upload नहीं)
-- Default: anon users cannot write (secure)
