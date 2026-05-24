# Bhakti Sadhana (भक्ति साधना)

Hindi devotional Flutter app — Sanatan Dharma traditional worship guidance.

## Features

- पूजा विधि, आरती, भजन, मंत्र, त्योहार, व्रत कथा
- In-app aarti audio (Supabase Storage + `just_audio`)
- Temple-themed UI with deity and category content

## Setup

```bash
flutter pub get
```

Configure Supabase in `lib/config/supabase_config.dart`, create the `aartis` bucket, and upload MP3s per `assets/content/aarti_audio.json`. See `docs/` and `scripts/setup_supabase.sh`.

## Run

```bash
flutter run
```
