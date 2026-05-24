#!/bin/bash
# Sirf Android — iPhone / Xcode ki zaroorat nahi
set -e

echo "=== Android Setup (भक्ति साधना) ==="

if ! command -v brew &>/dev/null; then
  echo "Pehle Homebrew install karo: https://brew.sh"
  exit 1
fi

echo "Step 1: Java + Android SDK (password maangega)..."
brew install --cask temurin android-commandlinetools android-platform-tools

export ANDROID_HOME="$HOME/Library/Android/sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"

BREW_SDK="/opt/homebrew/share/android-commandlinetools"
if [ -d "$BREW_SDK/cmdline-tools/latest" ]; then
  ln -sfn "$BREW_SDK/cmdline-tools/latest" "$ANDROID_HOME/cmdline-tools/latest"
fi

export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
if [ -d "$(brew --prefix)/share/android-platform-tools" ]; then
  export PATH="$(brew --prefix)/share/android-platform-tools:$PATH"
fi

echo "Step 2: SDK packages + licenses..."
yes | sdkmanager --licenses || true
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

flutter config --android-sdk "$ANDROID_HOME"

# Shell ke liye permanent (optional)
SHELL_RC="$HOME/.zshrc"
if ! grep -q "ANDROID_HOME" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# Android SDK" >> "$SHELL_RC"
  echo "export ANDROID_HOME=\"\$HOME/Library/Android/sdk\"" >> "$SHELL_RC"
  echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools\"" >> "$SHELL_RC"
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"
flutter pub get

echo ""
flutter doctor
echo ""
echo "Ab phone USB se connect karo (USB debugging ON) aur chalao:"
echo "  flutter devices"
echo "  flutter run"
