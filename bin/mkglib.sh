#!/usr/bin/env bash
set -e

d="$HOME/.local/share/glib-2.0/schemas"
rm -rf "$d"
mkdir -p "$d"

for i in $(ls -rt /nix/store/*gtk*/share/gsettings-schemas/*gtk*/glib-2.0/schemas/*); do
    yes | cp --no-preserve=mode,ownership -pif "$i" "$d/"
done
