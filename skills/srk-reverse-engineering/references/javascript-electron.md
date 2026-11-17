# JavaScript and Electron apps

## With the SRK engine
`analyze_javascript_application` with the ASAR or extracted folder → module
graph, imports, Electron main/renderer/preload boundaries, IPC channels.
`inspect_electron_fuses` for packaged fuse settings.
CLI equivalent (no MCP needed):
```bash
npx -y rea-agents@6.9.0 analyze-javascript-application /abs/path/to/app --json
```

## Terminal fallback
Find the ASAR:
- Windows: `%LOCALAPPDATA%\Programs\<App>\resources\app.asar`
- macOS: `<App>.app/Contents/Resources/app.asar`
- Linux: `/opt/<App>/resources/app.asar`
```bash
npx -y @electron/asar extract app.asar srk-re-work/<name>/app
cat srk-re-work/<name>/app/package.json     # "main" = entry file
npx -y prettier --write "srk-re-work/<name>/app/**/*.js"   # un-minify layout
```

## Checklist
- `package.json`: name, version, main, dependencies (shows the tech stack).
- Main process: `BrowserWindow` options — `nodeIntegration`,
  `contextIsolation`, `sandbox`, `webSecurity`. Flag insecure combinations.
- Preload: `contextBridge.exposeInMainWorld` = the API the UI can call.
- IPC: `ipcMain.handle/on` channel names = the app's internal commands.
- Native modules: `*.node` files → treat as native binaries.
- Source maps (`*.js.map`) recover original file names and code — check first.
- Auto-update URLs, telemetry endpoints, embedded keys (mask values).

## Finding a feature
Search UI text in renderer bundles → find the handler → follow IPC to the
main process → find the Node/OS API it ends in.
