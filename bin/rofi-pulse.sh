#!/usr/bin/env bash

main_menu() {
	echo -e "🔊 Set Output\n🎤 Set Input\n📶 Manage Streams\n🔇 Mute/Unmute"
}

output_menu() {
	pactl list short sinks | awk -F'\t' '{print $2}'
}

input_menu() {
	pactl list short sources | grep -v monitor | awk -F'\t' '{print $2}'
}

streams_menu() {
	pactl list sink-inputs short | awk '{print $1 " - " $2}'
}

mute_menu() {
	echo -e "Toggle Mute Output\nToggle Mute Input"
}

handle_output() {
	selected_sink="$1"
	sink_index=$(pactl list short sinks | grep "$selected_sink" | cut -f1)
	[ -n "$sink_index" ] && pactl set-default-sink "$sink_index"
}

handle_input() {
	selected_source="$1"
	source_index=$(pactl list short sources | grep "$selected_source" | cut -f1)
	[ -n "$source_index" ] && pactl set-default-source "$source_index"
}

handle_stream() {
	stream_id=$(echo "$1" | cut -d' ' -f1)
	sink_list=$(pactl list short sinks | awk -F'\t' '{print $2}')
	chosen_sink=$(echo "$sink_list" | rofi -dmenu -p "Move stream $stream_id to:")
	sink_index=$(pactl list short sinks | grep "$chosen_sink" | cut -f1)
	[ -n "$sink_index" ] && pactl move-sink-input "$stream_id" "$sink_index"
}

handle_mute() {
	case "$1" in
	Toggle\ Mute\ Output) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
	Toggle\ Mute\ Input) pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
	esac
}

main() {
	choice=$(main_menu | rofi -dmenu -p "PulseAudio Menu")
	case "$choice" in
	"🔊 Set Output")
		selected=$(output_menu | rofi -dmenu -p "Select Output")
		handle_output "$selected"
		;;
	"🎤 Set Input")
		selected=$(input_menu | rofi -dmenu -p "Select Input")
		handle_input "$selected"
		;;
	"📶 Manage Streams")
		selected=$(streams_menu | rofi -dmenu -p "Select Stream")
		[ -n "$selected" ] && handle_stream "$selected"
		;;
	"🔇 Mute/Unmute")
		selected=$(mute_menu | rofi -dmenu -p "Mute Options")
		handle_mute "$selected"
		;;
	esac
}

main
