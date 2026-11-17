#!/usr/bin/env bash
# SRK RE doctor — show which analysis tools are installed.
# Works on Linux, macOS and Windows (Git Bash / WSL).

ok()   { printf "  [OK]      %-12s %s\n" "$1" "$2"; }
miss() { printf "  [MISSING] %-12s install: %s\n" "$1" "$2"; }

check() {  # name, command, install hint
  if command -v "$2" >/dev/null 2>&1; then
    ver=$("$2" --version 2>/dev/null | head -1 | cut -c1-50)
    ok "$1" "$ver"
  else
    miss "$1" "$3"
  fi
}

echo "SRK RE doctor"
echo "============="
echo "SRK engine (MCP, powers deep analysis):"
if command -v node >/dev/null 2>&1; then
  major=$(node -v | sed 's/v\([0-9]*\).*/\1/')
  if [ "$major" -ge 20 ]; then ok "node" "$(node -v) — engine can start"
  else miss "node" "Node.js 20+ needed (you have $(node -v)) — https://nodejs.org"; fi
else
  miss "node" "Node.js 20+ — https://nodejs.org"
fi

echo
echo "Basic tools:"
check "file"      file      "apt install file / brew install libmagic"
check "strings"   strings   "apt install binutils / Xcode CLT"
check "unzip"     unzip     "apt install unzip / brew install unzip"
check "sha256sum" sha256sum "coreutils (macOS: use 'shasum -a 256')"

echo
echo "Android:"
check "jadx"      jadx      "https://github.com/skylot/jadx/releases (or: brew install jadx)"
check "apktool"   apktool   "https://apktool.org (or: brew install apktool)"
check "apksigner" apksigner "Android SDK build-tools"
check "java"      java      "Java 17+ (needed by jadx, apktool, Ghidra) — https://adoptium.net"

echo
echo "Native / .NET:"
if [ -n "$GHIDRA_INSTALL_DIR" ] && [ -x "$GHIDRA_INSTALL_DIR/support/analyzeHeadless" ]; then
  ok "ghidra" "$GHIDRA_INSTALL_DIR"
else
  miss "ghidra" "https://ghidra-sre.org then set GHIDRA_INSTALL_DIR=<folder>"
fi
check "radare2"   r2        "https://rada.re (or: brew install radare2)"
check "ilspycmd"  ilspycmd  "dotnet tool install -g ilspycmd"
check "upx"       upx       "apt install upx / brew install upx"

echo
echo "Firmware / captures:"
check "binwalk"   binwalk   "pip install binwalk / apt install binwalk"
check "unblob"    unblob    "pip install unblob"
check "tshark"    tshark    "Wireshark — https://www.wireshark.org"
check "jq"        jq        "apt install jq / brew install jq"
