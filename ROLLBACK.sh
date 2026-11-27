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
changed = b"""    -- LogService exposes MessageOut(message, messageType). OnClientMessage is
    -- not a Roblox LogService member and raised a red runtime error at boot.
    connect(LogService.MessageOut, function(message, messageType)
"""
original = b"""    connect(LogService.OnClientMessage, function(messageType, message)
"""

if data.count(changed) != 1:
    raise SystemExit("ERROR: LogService-fix block was not found exactly once")
path.write_bytes(data.replace(changed, original, 1))
PY

echo "RESTORED: $target_file"
