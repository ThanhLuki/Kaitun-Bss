#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${1:-$script_dir}"
modified="$target_dir/KaitunBSS.lua"
original="$target_dir/kaitun_v1.2.lua"

if [[ ! -f "$modified" ]]; then
  echo "ERROR: missing $modified" >&2
  exit 1
fi
if [[ -e "$original" ]]; then
  echo "ERROR: destination already exists: $original" >&2
  exit 1
fi

mv -- "$modified" "$original"
echo "RESTORED: $original"
