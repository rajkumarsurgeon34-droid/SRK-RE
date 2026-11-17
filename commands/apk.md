---
description: Full Android APK report — framework, permissions, endpoints, SDKs, security
argument-hint: <path-to-apk> [feature to explain]
---

APK and question: $ARGUMENTS

Use the `srk-reverse-engineering` skill and `references/android.md`.
Produce an Android report covering:
- App identity: package, version, min/target SDK, signing certificate.
- Framework (Flutter, React Native, Unity, Xamarin, Cordova, native) and
  where the real logic lives.
- Permissions, grouped as normal / dangerous, with why the app likely uses
  each one (evidence: the code that calls it).
- Exported components and other manifest risks.
- Servers and API endpoints the app talks to.
- Third-party SDKs (analytics, ads, payments, crash reporting).
- Secrets left in the code (type and location, values masked).
- If a feature was named: how it works, step by step, with evidence.

Write `srk-re-work/<apk-name>/SRK-RE-REPORT.md` and summarise in chat.
