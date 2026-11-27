#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${1:-$script_dir}"
target_file="$target_dir/KaitunBSS.lua"

if [[ ! -f "$target_file" ]]; then
  echo "ERROR: missing $target_file" >&2
  exit 1
fi

python - "$target_file" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
data = path.read_bytes()
changed = b"""    -- Keep the xpcall result on Runtime instead of allocating two more
    -- top-level locals. Luau caps a function at 200 local registers, and this
    -- main chunk is already at that limit on executor builds based on 0.700.
    Runtime.ProgressionOk, Runtime.ProgressionError = xpcall(progression, debug.traceback)
    if Runtime.ProgressionOk then break end
    reportError(\"Progression\", Runtime.ProgressionError)
"""
original = b"""    local okProgression, progressionError = xpcall(progression, debug.traceback)
    if okProgression then break end
    reportError(\"Progression\", progressionError)
"""

if data.count(changed) != 1:
    raise SystemExit("ERROR: register-fix block was not found exactly once")
path.write_bytes(data.replace(changed, original, 1))
PY

echo "RESTORED: $target_file"
