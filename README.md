# SRK RE

**Reverse engineer apps and files with Claude Code.** Part of the SRK family by
ShazVerse Technologies.

See a feature you like in an app. Understand how it works. Build your own
version. Or check your own release build before you publish it.

## What it can analyse
- Android apps: APK, AAB, XAPK (Flutter, React Native, Unity, Xamarin, native)
- Electron and JavaScript apps: ASAR files, app folders, web bundles
- Windows, Linux and macOS programs: EXE, DLL, ELF, Mach-O
- .NET assemblies
- Firmware images
- Network captures: HAR, PCAP, SAZ

## Install
In Claude Code:
```
/plugin marketplace add rajkumarsurgeon34-droid/srk-re
/plugin install srk-re@srk
```
Restart Claude Code, then run `/srk-re:doctor`.

Requirements: **Node.js 20+** (for the SRK engine). Optional but recommended:
Java 17+, [JADX](https://github.com/skylot/jadx), [apktool](https://apktool.org),
[Ghidra](https://ghidra-sre.org) (set `GHIDRA_INSTALL_DIR`).

## Commands
| Command | What it does |
|---|---|
| `/srk-re:doctor` | Shows which tools are installed and how to add missing ones |
| `/srk-re:analyze <file> [question]` | Scans any app or file and writes a report |
| `/srk-re:apk <file.apk> [feature]` | Full Android report: framework, permissions, servers, SDKs, secrets |
| `/srk-re:explain-feature <app> "<feature>"` | Explains how one feature works and designs your own version |
| `/srk-re:audit-my-app <build>` | Checks your own release build for leaked keys and insecure settings |

You can also just ask: *"How does the offline mode in this APK work?"*

Reports are saved to `srk-re-work/<target>/` in your current folder.

## How it works
- **SRK engine** — an MCP server based on the open-source
  [REA](https://github.com/morluto/rea) engine (`rea-agents`, MIT licence) that
  gives Claude structured tools for binaries, APKs, Electron apps, firmware and
  captures.
- **SRK skill** — a step-by-step workflow and guides for each kind of target.
- **SRK scripts** — `srk-doctor.sh`, `srk-triage.sh` and `srk-ghidra.sh`, which
  work even when the engine isn't running.

Everything runs on your own computer. Files are not uploaded anywhere by the
plugin.

## Use responsibly
Analyse software you own, have permission to test, or are studying for
learning, interoperability or security research on your own systems. Don't
use SRK RE to bypass licences, DRM or paid features, or to take other people's
data. Reimplement ideas; don't copy proprietary code or assets.

## Licence
MIT © 2026 Dr. M. Rajkumar, ShazVerse Technologies. The SRK engine uses REA by
morluto (MIT); see `THIRD_PARTY_NOTICES.md`.
