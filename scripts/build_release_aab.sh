#!/usr/bin/env bash
# Play Store release — hamesha dart_defines.json ke saath (YouTube API + AdMob flags).
set -euo pipefail
cd "$(dirname "$0")/.."

DEFINES="${1:-dart_defines.json}"
if [[ ! -f "$DEFINES" ]]; then
  echo "Missing $DEFINES — copy dart_defines.example.json and add YOUTUBE_API_KEY."
  exit 1
fi

echo "→ AdMob sync from Supabase..."
dart run scripts/pull_admob_config_from_supabase.dart

echo "→ Flutter release app bundle (dart-defines: $DEFINES)..."
flutter build appbundle --release --dart-define-from-file="$DEFINES"

# flutter build kabhi strip warning par fail ho jata hai; AAB phir bhi ban sakta hai
AAB="build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$AAB" ]]; then
  echo "→ Fallback: Gradle bundleRelease..."
  export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
  (cd android && ./gradlew :app:bundleRelease)
fi

if [[ -f "$AAB" ]]; then
  ls -lh "$AAB"
  echo ""
  echo "Upload: $AAB"
else
  echo "AAB not found — build failed."
  exit 1
fi
