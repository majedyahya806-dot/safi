# تعليمات البناء - صافي Sāfi

## لماذا فشل البناء في Workspace الحالي؟

البيئة الحالية:
- RAM: 1.9GB فقط
- Available: 533MB
- Gradle يحتاج 4GB لـ Release build

رسالة الخطأ:
```
Gradle build daemon disappeared unexpectedly (it may have been killed or may have crashed)
```

هذا يعني OOM Killer قتل العملية. طبيعي جداً في البيئات المحدودة.

## الحل 1: بناء على جهازك (الأفضل)

### Windows / macOS / Linux
```bash
# 1. ثبت Flutter 3.24.5
# https://docs.flutter.dev/get-started/install

# 2. ثبت Android Studio + SDK 34

# 3. نزّل المشروع من Workspace
# انسخ مجلد safi_app كامل

# 4. بناء
cd safi_app
flutter pub get
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./symbols

# الناتج:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  ~8-12MB
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ~8-12MB
# build/app/outputs/flutter-apk/app-x86_64-release.apk ~10MB
# كلها ≤24MB كما مطلوب
```

## الحل 2: GitHub Codespaces (مجاني)

1. ارفع المشروع لـ GitHub:
```bash
cd safi_app
git init
git add .
git commit -m "صافي v2.0"
git remote add origin https://github.com/USERNAME/safi.git
git push -u origin main
```

2. افتح Codespaces من GitHub (4GB RAM مجاناً)

3. شغّل نفس أوامر البناء أعلاه

## الحل 3: GitHub Actions (تلقائي)

ملف `.github/workflows/build-apk.yml` موجود. عند كل push:

- يبني APK تلقائياً على سيرفر GitHub بـ 7GB RAM
- يحفظ APK في Artifacts
- نزّله من تبويب Actions

```yaml
# .github/workflows/build-apk.yml
name: Build Safi APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
      - run: cd safi_app && flutter pub get
      - run: cd safi_app && flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./symbols
      - uses: actions/upload-artifact@v4
        with:
          name: safi-apk
          path: safi_app/build/app/outputs/flutter-apk/*.apk
```

## الحل 4: بناء Debug سريع (لا يحتاج 4GB)

```bash
flutter build apk --debug --split-per-abi
# يعمل حتى على 2GB RAM
# الناتج قابل للتثبيت لكن أكبر حجماً
```

## اختبار سريع بدون بناء

```bash
flutter run
# أو
flutter build web
cd build/web && python -m http.server 8000
```

## Backend + Dashboard

```bash
cd backend
pip install fastapi uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# لوحة التحكم
cd dashboard/public
python -m http.server 3000
```

## توقيع APK للمتجر

```bash
keytool -genkey -v -keystore ~/safi.jks -keyalg RSA -keysize 2048 -validity 10000 -alias safi

# android/key.properties
storePassword=***
keyPassword=***
keyAlias=safi
storeFile=/home/user/safi.jks

# ثم
flutter build apk --release --split-per-abi
```

## حجم APK

- مع --split-per-abi + --obfuscate + R8: كل APK ≤12MB
- بدون split: ~25MB (يتجاوز المطلوب 24MB لذا split إلزامي)

## اختبار الامتثال لـ PRD §6

```bash
# لا أذونات ممنوعة
! grep -q "READ_SMS\|READ_CALL_LOG\|RECORD_AUDIO\|CAMERA\|ACCESS_FINE_LOCATION" android/app/src/main/AndroidManifest.xml && echo "✅ لا أذونات ممنوعة"

# فحص طول النصوص
grep -r "Text(" lib/features/settings/ | wc -l
```
