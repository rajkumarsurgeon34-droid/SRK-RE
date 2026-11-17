#!/usr/bin/env bash
# SRK RE triage — identify a file and run a quick first-pass scan.
# Usage: srk-triage.sh <file>
set -u
f="${1:-}"
[ -z "$f" ] && { echo "Usage: srk-triage.sh <file>"; exit 1; }
[ -e "$f" ] || { echo "Not found: $f"; exit 1; }

hash_of() { if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }

echo "== SRK RE triage =="
echo "File:    $f"
if [ -d "$f" ]; then
  echo "Type:    directory"
  [ -f "$f/package.json" ] && { echo "Looks like: JavaScript/Electron app"; grep -E '"(name|version|main)"' "$f/package.json"; }
  find "$f" -name "*.asar" -o -name "*.node" 2>/dev/null | head -10
  exit 0
fi
echo "Size:    $(wc -c < "$f" | tr -d ' ') bytes"
echo "SHA-256: $(hash_of "$f")"
desc=$(file -b "$f")
echo "Type:    $desc"
echo

lower=$(echo "$f" | tr 'A-Z' 'a-z')
is_zip=0; echo "$desc" | grep -qiE 'zip|java archive|android' && is_zip=1

if [ $is_zip -eq 1 ] || [[ "$lower" == *.apk || "$lower" == *.aab || "$lower" == *.xapk || "$lower" == *.ipa || "$lower" == *.jar ]]; then
  list=$(unzip -l "$f" 2>/dev/null)
  echo "Archive entries: $(echo "$list" | tail -1 | awk '{print $2}')"
  if echo "$list" | grep -q "AndroidManifest.xml"; then
    echo "Kind:    Android package"
    echo -n "Framework: "
    if   echo "$list" | grep -q "libflutter.so";              then echo "Flutter (logic in libapp.so)"
    elif echo "$list" | grep -q "index.android.bundle";       then echo "React Native (JS bundle in assets)"
    elif echo "$list" | grep -qE "libil2cpp.so|Managed/.*\.dll"; then echo "Unity"
    elif echo "$list" | grep -qE "libmonodroid.so|assemblies/"; then echo "Xamarin / .NET MAUI"
    elif echo "$list" | grep -qE "cordova.js|capacitor";      then echo "Cordova / Capacitor (web assets)"
    else echo "Native Java/Kotlin"; fi
    echo "DEX files: $(echo "$list" | grep -c 'classes.*\.dex')"
    echo "Native libs:"; echo "$list" | grep -oE 'lib/[^ ]+\.so' | awk -F/ '{print "  " $2}' | sort | uniq -c
  elif echo "$list" | grep -q "Payload/.*\.app/"; then
    echo "Kind:    iOS app (IPA)"
  elif echo "$list" | grep -q "META-INF/MANIFEST.MF"; then
    echo "Kind:    Java archive"
  else
    echo "Kind:    ZIP archive"; echo "$list" | head -15
  fi
elif echo "$desc" | grep -q "ELF"; then
  echo "Kind:    Linux/Android native binary (ELF)"
  command -v readelf >/dev/null && readelf -d "$f" 2>/dev/null | grep NEEDED | head -15
elif echo "$desc" | grep -qE "PE32|MS-DOS"; then
  echo "Kind:    Windows executable (PE)"
  echo "$desc" | grep -qi "mono\|\.net" && echo "Note:    .NET assembly — use ilspycmd"
  strings -n 4 "$f" | grep -qi "UPX!" && echo "Note:    UPX packed — unpack a copy with 'upx -d'"
elif echo "$desc" | grep -q "Mach-O"; then
  echo "Kind:    macOS/iOS native binary (Mach-O)"
elif [[ "$lower" == *.asar ]]; then
  echo "Kind:    Electron ASAR — extract with: npx -y @electron/asar extract \"$f\" out/"
elif echo "$desc" | grep -qiE "pcap|capture"; then
  echo "Kind:    Packet capture — use tshark"
elif [[ "$lower" == *.har ]]; then
  echo "Kind:    HAR web capture — JSON, parse with jq"
else
  echo "Kind:    other / possibly firmware — try: binwalk \"$f\""
fi

echo
echo "== Interesting strings (first 25) =="
strings -n 6 "$f" 2>/dev/null | grep -Eo 'https?://[A-Za-z0-9._~:/?#@!$&()*+,;=%-]+' | sort -u | head -25
echo
echo "== Possible secrets (masked) =="
strings -n 12 "$f" 2>/dev/null \
  | grep -Eo 'AIza[0-9A-Za-z_-]{35}|AKIA[0-9A-Z]{16}|sk_live_[0-9a-zA-Z]{20,}|ghp_[0-9A-Za-z]{36}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  | sort -u | head -10 | sed -E 's/^(.{4}).*/\1… (masked)/'
echo "(done)"
