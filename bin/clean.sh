#!/usr/bin/env bash

set -euo pipefail

dirs=(
  ".zig-cache"
  ".cache"
  ".clangd"
  ".ccls-cache"
  "zig-out"
  "node_modules"
)

for dir in "${dirs[@]}"; do
  find . -type d -name "$dir" -prune -exec rm -rf {} +
done

if find . -name "Cargo.toml" -print -quit | grep -q .; then
  find . -type d -name "target" -prune -exec rm -rf {} +
fi

if find . -name "package.json" -print -quit | grep -q .; then
  find . -type d -name "dist" -prune -exec rm -rf {} +
fi
