# Firmware images

## With the SRK engine
`inspect_firmware_regions` to map regions; `extract_firmware` into a new,
empty absolute output folder when extraction is requested. ESP32 images
(first byte `0xE9`): `inspect_artifact`.

## Terminal fallback
```bash
binwalk target.bin                         # signatures and offsets
binwalk -E target.bin                      # entropy: flat high = encrypted/compressed
binwalk -eM -C srk-re-work/<name>/ex target.bin   # recursive extract
# or: unblob -e srk-re-work/<name>/ex target.bin
```
Typical contents: bootloader (U-Boot), kernel (uImage/zImage), root
filesystem (SquashFS, JFFS2, UBIFS, CramFS), device tree (`.dtb`).

## Checklist
- Root filesystem: `/etc/passwd`, `/etc/shadow`, init scripts, web server
  config, default credentials (report masked), telnet/ssh enabled.
- Busybox version and other components with known CVEs.
- Main service binaries → analyse as native ELF (`references/native.md`),
  often ARM or MIPS.
- Update mechanism: signature checks present or absent.
