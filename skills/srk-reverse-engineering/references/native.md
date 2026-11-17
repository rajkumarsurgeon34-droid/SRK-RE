# Native binaries (ELF, PE, Mach-O) and .NET

## With the SRK engine
`open_binary` (path) → `inspect_artifact` for headers, sections, imports,
exports, strings, hardening. Then decompile/xref tools as advertised (the
engine uses Ghidra, IDA or Hopper when configured — see `/srk-re:doctor`).
.NET: `inspect_managed_artifact`.

## Terminal fallback
```bash
file target; sha256sum target
readelf -h -d -S target        # ELF headers, libraries, sections
objdump -p target.exe          # PE imports (or: rabin2 -I -i target.exe)
strings -n 6 target | less     # also: strings -e l (UTF-16 on Windows)
bash ${CLAUDE_PLUGIN_ROOT}/scripts/srk-ghidra.sh target srk-re-work/<name>/ghidra
```
`srk-ghidra.sh` writes one `.c` file per function plus `functions.txt`.
Quick alternative without Ghidra: `r2 -A target` then `afl`, `pdf @ sym.main`.

.NET (PE with a CLI header, `file` says "Mono/.Net assembly"):
```bash
dotnet tool install -g ilspycmd
ilspycmd -p -o srk-re-work/<name>/src target.dll
```

## Checklist
- Architecture, compiler/language (Go: `go.buildid`; Rust: `rust_panic`;
  Delphi; Qt: `Qt5Core`), packer (UPX: `upx -d` on a copy).
- Imports tell the story: networking (`WinHttp`, `libcurl`), crypto
  (`bcrypt`, `libssl`), registry, file and process APIs.
- Hardening: PIE/ASLR, NX/DEP, stack canaries, RELRO, CFG, signing
  (`checksec --file=target`).
- Strings: URLs, file paths, error messages, format strings, version.

## Finding a feature
Pick a unique string from the feature (error text, menu label) → find its
cross-references → decompile those functions → rename variables as you
understand them → summarise the algorithm in plain language.
