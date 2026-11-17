---
description: Check which SRK RE analysis tools are installed and how to install missing ones
allowed-tools: Bash
---

Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/srk-doctor.sh"` and show the result.

Then tell the user, in plain language:
1. Whether the **SRK engine** (MCP server `srk-engine`) tools are available in
   this session — check your own tool list for names like `open_binary` or
   `inspect_android_package`. If not, say it needs Node.js 20+ and a Claude
   Code restart after installing the plugin.
2. Which target types they can analyse right now (Android, Electron/JS,
   native, .NET, firmware, captures).
3. The exact install commands for anything missing that matters for what
   they want to do. Do not install anything without asking.
