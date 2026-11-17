# Websites, web apps and network captures

## Static bundle analysis (default)
1. Fetch the page HTML and list `<script src>` bundles.
2. Download each bundle into `srk-re-work/<site>/js/`. Check for `*.js.map`
   (the `//# sourceMappingURL=` comment); source maps recover the original
   files: `npx -y source-map-explorer` or unpack with a small script.
3. Beautify: `npx -y prettier --write "js/*.js"`.
4. Identify the framework: React (`__REACT_DEVTOOLS`, `createElement`),
   Next.js (`/_next/`, `__NEXT_DATA__`), Vue, Angular, Svelte.
5. Extract API endpoints: `grep -Eoh '"/api/[^"]+"|https?://[^" ]+' js/*.js | sort -u`.

## Live behaviour (only with the user's own browser session)
With the SRK engine: `list_browser_targets` for a page the user already has
open, `capture_browser_scenario` for declared clicks/typing. Pass the page
origin **and** API origins in `allowed_origins`.
Without it: ask the user to export a HAR from browser DevTools
(Network → right-click → Save all as HAR) and analyse that file.

## Captures
- HAR / SAZ / qlog: engine `inspect_web_network_capture`, else parse the HAR
  JSON with `jq '.log.entries[] | {m:.request.method,u:.request.url,s:.response.status}'`.
- PCAP: engine `inspect_pcap_capture`, else
  `tshark -r file.pcap -q -z conv,ip` and `-Y dns` / `-Y http.request`.

## Rules
Respect robots.txt and terms of service; no credential stuffing, no load
testing, no access to areas the user is not authorised for. Strip cookies and
auth headers from anything you save or report.
