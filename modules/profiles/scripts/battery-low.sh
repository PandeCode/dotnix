for battery in /sys/class/power_supply/BAT*; do
	capacity=$(<"$battery/capacity")
	status=$(<"$battery/status")
	if [[ $status == Discharging ]] && ((capacity <= 5)); then
		notify-send --urgency=critical "Low battery" "$capacity%"
	fi
done
