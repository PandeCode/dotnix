#!/run/current-system/sw/bin/bash

theme="$1"

# Check if theme is a single word
if [[ ! "$theme" =~ ^[a-zA-Z0-9_]+$ ]]; then
    notify-send "Error" "Theme must be a single word."
    exit 1
fi

# Check if the file exists
file_path="$(home-manager generations | head -1 | perl -pe 's/.*-> //g')/specialisation/${theme}/activate"
if [[ ! -f "$file_path" ]]; then
    available_themes=$(ls "$(home-manager generations | head -1 | perl -pe 's/.*-> //g')/specialisation")
    notify-send "Error" "The file for theme '$theme' does not exist. Available themes: $available_themes"
    exit 1
fi

bash -c "$(ls "$file_path")"
