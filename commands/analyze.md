---
description: Reverse engineer any app or file and write an SRK RE report
argument-hint: <path-to-file> [what you want to understand]
---

Target and question: $ARGUMENTS

Use the `srk-reverse-engineering` skill. Steps:
1. Confirm the file exists. If the user's purpose is unclear or the target
   looks like someone else's commercial software, ask one short question about
   authorisation before going deeper.
2. Triage with the SRK engine tools if available, otherwise
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/srk-triage.sh" <file>`.
3. Route to the matching reference guide and follow the investigation loop.
4. If the user asked about a specific feature, focus on it; otherwise give an
   overview of architecture, framework, endpoints and notable behaviour.
5. Write `srk-re-work/<target>/SRK-RE-REPORT.md` in the skill's report format
   and give a short plain-language summary in chat.
