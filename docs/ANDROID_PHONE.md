# Android phone par app chalana

## A — Ek baar Mac par setup (15–20 min)

### Option 1: Script (recommended)

Terminal kholo:

```bash
cd /Users/rahulkumar/Apps_vive_coded/Apps/App3
bash scripts/setup_android.sh
```

Mac password do jab maange. Khatam hone par `flutter doctor` mein Android ✓ hona chahiye.

### Option 2: Android Studio (aasaan UI)

1. Download: https://developer.android.com/studio  
2. Install karo, open karo → **SDK** install hone do  
3. Terminal:

```bash
flutter config --android-sdk ~/Library/Android/sdk
flutter doctor
```

---

## B — Phone tayyar karo

1. **Settings → About phone** → **Build number** par **7 baar tap**  
2. **Settings → Developer options** → **USB debugging** ON  
3. **Data cable** se Mac se connect  
4. Phone par **Allow USB debugging** → Allow (हमेशा के लिए ✓)

---

## C — App chalao

```bash
cd /Users/rahulkumar/Apps_vive_coded/Apps/App3
flutter devices
```

Aapke phone ka naam aana chahiye, jaise:

`SM G991B` ya `motorola edge` ...

Phir:

```bash
flutter run
```

Sirf Android force karna ho:

```bash
flutter run -d android
```

Pehli build 5–10 minute lag sakti hai.

---

## Problem?

| Problem | Fix |
|---------|-----|
| `flutter devices` mein phone nahi | Cable badlo, debugging ON, phone unlock rakho |
| `adb` not found | `bash scripts/setup_android.sh` dubara |
| `Android SDK not found` | `flutter config --android-sdk ~/Library/Android/sdk` |
| Install blocked | Phone par **Install unknown apps** allow / purana app hatao |

Check:

```bash
adb devices
```

`device` dikhna chahiye ( `unauthorized` ho to phone par Allow dabao).
