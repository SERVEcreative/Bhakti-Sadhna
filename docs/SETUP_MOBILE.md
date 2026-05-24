# Phone par app kaise chalayein (Mac Setup)

## Aapke Mac par abhi kya missing hai

| Tool | Status | Kaam |
|------|--------|------|
| **Xcode** | Install nahi | iPhone par app |
| **Android SDK** | Install nahi | Android phone par app |
| **CocoaPods** | Install nahi | iPhone plugins |

---

## Step 1 — Ek baar setup script chalao

Mac par **Terminal** kholo aur ye commands:

```bash
cd /Users/rahulkumar/Apps_vive_coded/Apps/App3
chmod +x scripts/setup_mac_mobile.sh
bash scripts/setup_mac_mobile.sh
```

- Password maangega (`sudo`) — apna Mac password dalo  
- **Xcode** App Store se download hoga / install karna hoga  
- **Android SDK** + Java install honge  

Script khatam hone ke baad `flutter doctor` mein ✓ dikhna chahiye.

---

## Step 2 — Xcode (iPhone)

1. App Store → **Xcode** install (~12 GB, 30–60 min)  
2. Pehli baar Xcode kholo → license accept  
3. Dubara script chalao ya manually:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo gem install cocoapods
```

4. iPhone USB se connect → **Trust**  
5. iPhone: Settings → Privacy → **Developer Mode** ON  

**Signing (pehli baar):**

```bash
cd /Users/rahulkumar/Apps_vive_coded/Apps/App3
open ios/Runner.xcworkspace
```

Xcode → Runner → Signing & Capabilities → Team = apna Apple ID

---

## Step 3 — Android phone

1. Settings → About → Build number **7 tap**  
2. Developer options → **USB debugging** ON  
3. USB cable se Mac connect → Allow debugging  

```bash
flutter devices
```

Phone naam dikhna chahiye.

---

## Step 4 — App chalao

```bash
cd /Users/rahulkumar/Apps_vive_coded/Apps/App3
flutter run
```

Sirf Android:

```bash
flutter run -d android
```

Sirf iPhone:

```bash
flutter run -d ios
```

---

## Problem?

```bash
flutter doctor -v
adb devices          # Android — SDK install ke baad
```

Agar `adb` nahi mile:

```bash
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
```
