# turns every touchpad off or on through the kernel's inhibited switch, so it
# acts the same under x11, wayland and the console. the udev rule in
# modules/profiles/desktop.nix lets the input group write it
action=${1:-toggle}

case $action in
toggle | on | off) ;;
*)
	echo "usage: touchpad toggle|on|off" >&2
	exit 2
	;;
esac

pads=()
for dev in /sys/class/input/input*; do
	if [[ $(udevadm info --query=property --property=ID_INPUT_TOUCHPAD --value "$dev") == 1 ]]; then
		pads+=("$dev")
	fi
done

if ((${#pads[@]} == 0)); then
	notify-send "Touchpad" "none found"
	exit 1
fi

case $action in
on) inhibited=0 ;;
off) inhibited=1 ;;
toggle) inhibited=$((1 - $(cat "${pads[0]}/inhibited"))) ;;
esac

for pad in "${pads[@]}"; do
	if ! echo "$inhibited" >"$pad/inhibited"; then
		notify-send "Touchpad" "cannot write $pad/inhibited, reboot once after switching"
		exit 1
	fi
done

if ((inhibited)); then
	notify-send "Touchpad" "off"
else
	notify-send "Touchpad" "on"
fi
