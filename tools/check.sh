#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -x tools/bin/rojo || ! -x tools/bin/luau-compile || ! -x tools/bin/luau ]]; then
  echo 'Run ./tools/bootstrap.sh first.' >&2
  exit 1
fi
tools/bin/luau tests/Rules.spec.luau
bytecode_file="$(mktemp)"
trap 'rm -f "$bytecode_file"' EXIT
while IFS= read -r -d '' source; do
  tools/bin/luau-compile "$source" > "$bytecode_file"
done < <(find src tests -type f -name '*.luau' -print0)
echo 'PASS: all Luau files compile'
mkdir -p build
tools/bin/rojo build default.project.json -o build/LastDelivery.rbxlx
