# yazi as the file chooser of xdg-desktop-portal-termfilechooser. the portal
# passes: multiple, directory, save, path, the file to write the picks to,
# debug, then the terminal command from TERMCMD. see
# https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser/blob/main/xdg-desktop-portal-termfilechooser.5.scd
directory=$2
save=$3
path=$4
out=$5
shift 6

# the portal quotes ' as '\'' for a shell, but hands the path over as a
# plain argument
path=${path//"'\\''"/"'"}

export YAZI_PICKER_OUT=$out

if [[ $save == 1 ]]; then
	export YAZI_PICKER=save YAZI_PICKER_NAME=${path##*/}
	exec "$@" --title="Save $YAZI_PICKER_NAME" -e yazi "${path%/*}"
elif [[ $directory == 1 ]]; then
	export YAZI_PICKER=folder
	exec "$@" --title="Pick a folder" -e yazi "$path"
else
	export YAZI_PICKER=open
	exec "$@" --title="Open" -e yazi --chooser-file="$out" "$path"
fi
