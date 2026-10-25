#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'This bootstrap supports Linux x86_64. Install Rojo 7.5.1 and Luau 0.693 for your platform.' >&2
  exit 1
fi
mkdir -p tools/bin
download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT
curl --fail --location --retry 2 https://github.com/rojo-rbx/rojo/releases/download/v7.5.1/rojo-7.5.1-linux-x86_64.zip -o "$download_dir/rojo.zip"
curl --fail --location --retry 2 https://github.com/luau-lang/luau/releases/download/0.693/luau-ubuntu.zip -o "$download_dir/luau.zip"
(
  cd "$download_dir"
  echo '0d600df6c4c48a9d09c701d0c2a109c55c2db833cd9766fd7d1e6e2684843d53  rojo.zip' | sha256sum --check
  echo '1fe00c3bae12e0aacdf243cbd6dad737948106856e09ef1895f73e6adc036071  luau.zip' | sha256sum --check
)
unzip -o "$download_dir/rojo.zip" -d tools/bin
unzip -o "$download_dir/luau.zip" -d tools/bin
chmod +x tools/bin/rojo tools/bin/luau tools/bin/luau-compile tools/bin/luau-analyze tools/bin/luau-ast
tools/bin/rojo --version
