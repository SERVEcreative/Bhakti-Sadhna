#!/bin/bash
# भक्ति साधना — Mac par iPhone + Android development setup
# Terminal mein chalao: bash scripts/setup_mac_mobile.sh

set -e

echo "=========================================="
echo "  भक्ति साधना — Mobile Dev Setup (Mac)"
echo "=========================================="

# --- 1) Xcode (iPhone ke liye — App Store se) ---
if [ ! -d "/Applications/Xcode.app" ]; then
  echo ""
  echo "[Xcode] Abhi install nahi hai."
  echo "  → App Store khul raha hai — Xcode download/install karo (~12 GB)"
  echo "  → Install ke baad dubara ye script chalao."
  open "macappstore://apps.apple.com/app/id497799835" 2>/dev/null || open "https://apps.apple.com/app/xcode/id497799835"
else
  echo "[Xcode] Found ✓"
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  xcodebuild -version
fi

# --- 2) Homebrew packages (Android) ---
if ! command -v brew &>/dev/null; then
  echo "Homebrew install karo: https://brew.sh"
  exit 1
fi

echo ""
echo "[Android] Java + SDK tools install (password maangega)..."
brew install --cask temurin android-commandlinetools android-platform-tools

# SDK root — Flutter standard path
export ANDROID_HOME="$HOME/Library/Android/sdk"
mkdir -p "$ANDROID_HOME"

BREW_SDK="/opt/homebrew/share/android-commandlinetools"
if [ -d "$BREW_SDK" ]; then
  # cmdline-tools ko Flutter-friendly layout mein link karo
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  ln -sfn "$BREW_SDK/cmdline-tools/latest" "$ANDROID_HOME/cmdline-tools/latest" 2>/dev/null || true
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
fi

export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$(brew --prefix)/share/android-platform-tools:$PATH" 2>/dev/null || true

echo ""
echo "[Android] SDK packages download..."
yes | sdkmanager --licenses || true
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

flutter config --android-sdk "$ANDROID_HOME"

# --- 3) CocoaPods (iPhone plugins) ---
if command -v pod &>/dev/null; then
  echo "[CocoaPods] Already installed ✓"
else
  echo "[CocoaPods] Install..."
  sudo gem install cocoapods
fi

# --- 4) Flutter project ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

flutter pub get

if [ -d "ios" ] && command -v pod &>/dev/null && [ -d "/Applications/Xcode.app" ]; then
  echo ""
  echo "[iOS] pod install..."
  cd ios && pod install && cd ..
fi

echo ""
echo "=========================================="
flutter doctor
echo "=========================================="
echo ""
echo "Phone connect karo (USB debugging ON) phir:"
echo "  flutter devices"
echo "  flutter run"
echo ""
