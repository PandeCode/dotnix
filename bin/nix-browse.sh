#!/usr/bin/env bash

set -euo pipefail

# List installed packages
packages=$(nix-store --query --requisites /run/current-system | grep -v '\.drv$' | sort)

# FZF interface
echo "$packages" | fzf --preview '
pkg="{}"
info=$(nix path-info -S --json "$pkg" | jq -r ".[0]")
size=$(echo "$info" | jq -r ".narSize" | numfmt --to=iec)
name=$(basename "$pkg")

# Try to get meta info if available
desc=$(nix show-derivation "$pkg".drv 2>/dev/null | jq -r ".[].env.description // empty" | head -n1)
[ -z "$desc" ] && desc="(no description)"

# Compute dependencies and unique size
deps=$(nix-store --query --references "$pkg" | wc -l)
revdeps=$(nix-store --query --referrers "$pkg" | wc -l)
unique_size=$(nix-store --query --closure-size "$pkg" 2>/dev/null | awk "{print \$1}" | numfmt --to=iec)

echo "📦  $name"
echo "────────────────────────────"
echo "Size:           $size"
echo "Unique closure: $unique_size"
echo "Deps count:     $deps"
echo "Revdeps:        $revdeps"
echo
echo "📝 Description:"
echo "$desc"
'
