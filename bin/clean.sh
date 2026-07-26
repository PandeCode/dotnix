#!/usr/bin/env bash

TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
	echo "Directory not found: $TARGET_DIR"
	exit 1
fi

DIRS=(".direnv" "target" ".zig-cache" "zig-out" "zig-pkg" ".cargo" "node_modules" "__pycache__")
TOTAL=0
FOUND_DIRS=()

echo "Directories to delete:"
for dir in "${DIRS[@]}"; do
	while IFS= read -r path; do
		if [ -n "$path" ]; then
			size=$(du -sb "$path" 2>/dev/null | awk '{print $1}')
			echo "  $path ($(numfmt --to=iec "$size"))"
			TOTAL=$((TOTAL + size))
			FOUND_DIRS+=("$path")
		fi
	done < <(find "$TARGET_DIR" -name "$dir" -type d 2>/dev/null)
done

if [ $TOTAL -eq 0 ]; then
	echo "Nothing found."
	exit 0
fi

echo ""
echo "Total to recover: $(numfmt --to=iec $TOTAL)"
read -p "Delete? (y/N) " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
	for path in "${FOUND_DIRS[@]}"; do
		rm -rf "$path" 2>/dev/null
	done
	echo "Done"
fi
