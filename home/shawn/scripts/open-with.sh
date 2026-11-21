# picks an app for the files from those that open their type, like a file
# manager's "open with"
(($#)) || exit 0
type=$(gio info --attributes=standard::content-type "$1" | sed -n 's/^ *standard::content-type: //p')

IFS=: read -ra data_dirs <<<"${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-}"

desktop_file() {
	local dir
	for dir in "${data_dirs[@]}"; do
		if [[ -f $dir/applications/$1 ]]; then
			echo "$dir/applications/$1"
			return
		fi
	done
}

# one "id<tab>name" line per app, the default one first
apps() {
	local id file name
	gio mime "$type" | sed -n 's/^\t//p' | awk '!seen[$0]++' | while read -r id; do
		file=$(desktop_file "$id")
		name=
		if [[ -n $file ]]; then
			name=$(sed -n 's/^Name=//p' "$file" | head -n 1)
		fi
		printf '%s\t%s\n' "$id" "${name:-$id}"
	done
}

choice=$(apps | rofi -dmenu -i -p "open with" -display-columns 2 -display-column-separator '\t') || exit 0
exec gtk-launch "${choice%%$'\t'*}" "$@"
