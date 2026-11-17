---
name: srk-reverse-engineering
description: Reverse engineer a shipped app or file (Android APK/AAB, Electron/JavaScript app or ASAR, Windows/Linux/macOS binary, .NET assembly, website bundle, firmware image, network capture) to explain how a feature works, audit your own release build, or guide building a similar feature. Use when the answer depends on a compiled or packaged artifact rather than readable source code. Skip for ordinary source repositories.
---

# SRK RE — reverse engineering workflow

SRK RE has two layers. Use the strongest one that is available.

1. **SRK engine (MCP)** — the plugin registers the `srk-engine` MCP server
   (the open-source REA engine, `rea-agents`). If its tools are in your tool
   list (names such as `open_binary`, `inspect_android_package`,
   `analyze_javascript_application`, `inspect_artifact`,
   `audit_release_exposure`), prefer them: they return structured Evidence
   with file offsets, hashes and stated limitations.
2. **SRK scripts (terminal)** — always available fallback, in
   `${CLAUDE_PLUGIN_ROOT}/scripts/`:
   - `srk-doctor.sh` — which analysis tools are installed, with install hints.
   - `srk-triage.sh <file>` — identify the file type and run a first-pass scan.
   - `srk-ghidra.sh <binary> <outdir>` — headless Ghidra decompile to C files.

If the engine tools are missing, do not stop: continue with the scripts and
tell the user once that `/srk-re:doctor` shows how to enable the engine
(Node.js 20+ is needed; Ghidra/JADX for deep native/Android work).

## Ground rules

- **Authorisation first.** Only analyse software the user owns, has
  permission to test, or is studying for interoperability, security research
  on their own systems, or learning. Do not help bypass licensing, DRM, paid
  features, anti-cheat, or extract other people's private data or
  credentials. If the purpose is unclear, ask one short question.
- **Never run the target** unless the user explicitly asks and understands it
  executes untrusted code. Static analysis is the default.
- **Work in a scratch folder** (`./srk-re-work/<target-name>/`). Never modify
  the original file. Record its SHA-256 at the start.
- **Evidence, not guesses.** Every claim in the report cites where it came
  from: file path inside the package, class/function name, offset, or string.
  Separate *Observed* facts from *Inferred* conclusions and list *Unknowns*.
- **Secrets:** if you find keys or tokens, report the type and location with
  the value masked (first 4 characters + `…`). Never print a full secret.

## Route by target

| Target | First step | Read |
|---|---|---|
| `.apk`, `.aab`, `.xapk` | engine `inspect_android_package`, else `srk-triage.sh` then JADX/apktool | `references/android.md` |
| `.asar`, Electron app folder, `.js` bundle | engine `analyze_javascript_application`, else `npx asar extract` | `references/javascript-electron.md` |
| ELF / PE `.exe` `.dll` / Mach-O | engine `open_binary` + `inspect_artifact`, else `srk-ghidra.sh` | `references/native.md` |
| .NET assembly | engine `inspect_managed_artifact`, else ilspycmd | `references/native.md` |
| Website / web app | download bundles, source maps, HAR | `references/web.md` |
| Firmware `.bin` `.img` | engine `inspect_firmware_regions`, else binwalk/unblob | `references/firmware.md` |
| `.pcap` `.har` `.saz` | engine capture tools, else tshark | `references/web.md` |
| Unknown | `srk-triage.sh <file>` | — |

## Standard investigation loop

1. **Triage** — type, size, hash, architecture, packer/obfuscator signs,
   framework (Flutter, React Native, Unity, Xamarin, Electron, Qt…).
2. **Map** — entry points, modules/packages, dependencies, permissions,
   network endpoints, embedded resources.
3. **Focus** — find the code for the feature the user asked about: search
   strings from the UI, resource IDs, API paths, then follow references.
4. **Explain** — describe the mechanism step by step in plain language, with
   the evidence trail.
5. **Rebuild (if asked)** — design an original implementation of the idea for
   the user's own project. Reimplement behaviour; do not copy proprietary code
   or assets.

## Report format

Write `srk-re-work/<target>/SRK-RE-REPORT.md`:

```
# SRK RE report — <target>
Target: <file>  SHA-256: <hash>  Date: <date>
## Summary (3–5 lines, plain language)
## What it is (type, framework, architecture, size)
## How <feature> works (step by step, each step with evidence)
## Network endpoints / permissions / third-party SDKs
## Security notes (masked secrets, debug flags, weak crypto)
## Unknowns and limits
## How to build something similar (original design, if requested)
```

Then give the user a short summary in chat and the report path.
