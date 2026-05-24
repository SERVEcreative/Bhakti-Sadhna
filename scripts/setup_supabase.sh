#!/usr/bin/env bash
# Supabase setup for भक्ति साधना aarti streaming
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Dependencies"
flutter pub get

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) https://supabase.com → New project (free tier)"
echo ""
echo "2) Project Settings → API:"
echo "   - Project URL  → lib/config/supabase_config.dart में url"
echo "   - anon public key → anonKey"
echo ""
echo "3) Storage → New bucket:"
echo "   Name: aartis"
echo "   Public bucket: ON"
echo ""
echo "4) SQL Editor → supabase/storage_policies.sql paste & Run"
echo ""
echo "5) bucket aartis में MP3 upload (names from assets/content/aarti_audio.json):"
echo "   jai_ganesh.mp3, shiv_aarti.mp3, ..."
echo ""
echo "6) flutter run"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
