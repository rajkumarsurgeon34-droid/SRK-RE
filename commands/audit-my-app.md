---
description: Check your own release build (APK, EXE, Electron app) before publishing
argument-hint: <path-to-your-build>
---

Build to audit: $ARGUMENTS

This is the user's own app. Use the `srk-reverse-engineering` skill.
If the SRK engine tool `audit_release_exposure` is available, run it first;
for APKs also run the Android checklist.

Look for what an attacker or competitor could extract from the shipped build:
- Hard-coded API keys, tokens, passwords, private keys (mask values).
- Debug flags left on (`debuggable`, dev servers, verbose logging,
  source maps shipped, test endpoints).
- Insecure settings (cleartext HTTP, `allowBackup`, exported components,
  Electron `nodeIntegration` without `contextIsolation`).
- Missing obfuscation/minification where it matters.
- Unsigned or debug-signed builds.

Output a table: **Issue | Severity (High/Medium/Low) | Where | How to fix**,
then a short "fix these first" list. Write it to
`srk-re-work/<build-name>/SRK-RE-AUDIT.md`.
