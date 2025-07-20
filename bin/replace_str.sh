#!/usr/bin/env bash

# Usage: ./replace.sh "old_string" "new_string"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <old_string> <new_string>"
  exit 1
fi

OLD="$1"
NEW="$2"

# Recursively find all files (excluding binary files) and replace string
find . -type f -exec grep -Il . {} \; | while read -r file; do
  sed -i "s/${OLD//\//\\/}/${NEW//\//\\/}/g" "$file"
done
