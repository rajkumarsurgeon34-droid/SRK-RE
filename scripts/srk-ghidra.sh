#!/usr/bin/env bash
# SRK RE — headless Ghidra decompile.
# Usage: srk-ghidra.sh <binary> <output-dir>
# Needs GHIDRA_INSTALL_DIR set to your Ghidra folder and Java 17+.
set -eu
bin="${1:?Usage: srk-ghidra.sh <binary> <output-dir>}"
out="${2:?Usage: srk-ghidra.sh <binary> <output-dir>}"
: "${GHIDRA_INSTALL_DIR:?Set GHIDRA_INSTALL_DIR to your Ghidra folder (https://ghidra-sre.org)}"
head="$GHIDRA_INSTALL_DIR/support/analyzeHeadless"
[ -x "$head" ] || { echo "analyzeHeadless not found in $GHIDRA_INSTALL_DIR/support"; exit 1; }

mkdir -p "$out"
out=$(cd "$out" && pwd)
proj=$(mktemp -d)
script_dir=$(mktemp -d)

cat > "$script_dir/SrkExport.java" <<'JAVA'
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import java.io.*;

public class SrkExport extends GhidraScript {
  @Override
  public void run() throws Exception {
    String out = getScriptArgs()[0];
    DecompInterface d = new DecompInterface();
    d.openProgram(currentProgram);
    PrintWriter index = new PrintWriter(new File(out, "functions.txt"));
    int n = 0;
    for (Function f : currentProgram.getFunctionManager().getFunctions(true)) {
      if (monitor.isCancelled()) break;
      index.println(f.getEntryPoint() + "  " + f.getName() + (f.isThunk() ? "  (thunk)" : ""));
      if (f.isThunk() || f.isExternal()) continue;
      DecompileResults r = d.decompileFunction(f, 60, monitor);
      if (r != null && r.decompileCompleted()) {
        String safe = f.getName().replaceAll("[^A-Za-z0-9_.-]", "_");
        try (PrintWriter w = new PrintWriter(new File(out, f.getEntryPoint() + "_" + safe + ".c"))) {
          w.println(r.getDecompiledFunction().getC());
        }
        n++;
      }
    }
    index.close();
    println("SRK: decompiled " + n + " functions to " + out);
  }
}
JAVA

echo "SRK: analysing $bin with Ghidra (large files can take several minutes)…"
"$head" "$proj" srk -import "$bin" -scriptPath "$script_dir" \
  -postScript SrkExport.java "$out" -deleteProject 2>&1 | grep -E "SRK:|ERROR" || true
rm -rf "$proj" "$script_dir"
echo "SRK: output in $out (index: functions.txt)"
