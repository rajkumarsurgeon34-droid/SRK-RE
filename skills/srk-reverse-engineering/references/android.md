# Android (APK / AAB / XAPK)

## With the SRK engine
`inspect_android_package` (path) → classes, methods, manifest, then focused
Android tools if advertised (class source, incoming references). For archive
member inventory use `open_binary` + `inspect_artifact`.

## Terminal fallback
```bash
W=srk-re-work/<name>; mkdir -p $W
sha256sum app.apk
unzip -l app.apk | head -50                 # what's inside
apktool d -f -o $W/apktool app.apk          # manifest + resources + smali
jadx -d $W/jadx --show-bad-code app.apk     # Java/Kotlin-like source
```
AAB: `bundletool build-apks --mode=universal` first. XAPK/APKM: unzip, then
analyse `base.apk` plus split APKs.

## Detect the framework
| Sign inside the APK | Framework | Where the app logic lives |
|---|---|---|
| `lib/*/libflutter.so`, `libapp.so` | Flutter | Dart AOT in `libapp.so` (use blutter / reFlutter; strings help) |
| `assets/index.android.bundle` | React Native | JS bundle (Hermes bytecode if starts with `c61fbc03` → `hermes-dec`) |
| `assets/bin/Data/Managed/*.dll` or `libil2cpp.so` | Unity | Mono DLLs (ILSpy) or IL2CPP (Il2CppDumper) |
| `assemblies/*.dll`, `libmonodroid.so` | Xamarin / .NET MAUI | .NET DLLs (ILSpy) |
| `assets/www/index.html`, `cordova.js` | Cordova / Capacitor | HTML/JS in assets |
| only `classes*.dex` | Native Java/Kotlin | JADX output |

## Checklist
- Manifest: package, versions, `minSdk`/`targetSdk`, permissions,
  exported activities/services/receivers/providers, `debuggable`,
  `allowBackup`, `usesCleartextTraffic`, network security config.
- Signing: `apksigner verify --print-certs app.apk`.
- Endpoints: `grep -rEoh 'https?://[^"'"'"' <>]+' $W/jadx | sort -u`.
- SDKs: Firebase, analytics, ads, payment, crash reporting (package names).
- Secrets: `AIza…` (Google), `sk_live_`, `AKIA`, private keys — mask values.
- Obfuscation: short class names (`a.b.c`) = R8/ProGuard; follow strings and
  Android API calls instead of names.

## Finding a feature
Search the UI text in `res/values/strings.xml` → get the resource name →
find its ID in `public.xml` → search that ID/name in JADX output → follow the
calling methods.
