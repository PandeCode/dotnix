#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  if (argc < 3)
	return 1;

  if (strcmp("key", argv[1]) == 0) {
	if (strcmp("up", argv[2]) == 0)
	  system("brightnessctl -d *::kbd_backlight set +33%");
	else if (strcmp("down", argv[2]) == 0)
	  system("brightnessctl -d *::kbd_backlight set 33%-");
	else
	  return 1;
  }

  else if (strcmp("vol", argv[1]) == 0) {
	if (strcmp("up", argv[2]) == 0)
	  system("pactl set-sink-volume @DEFAULT_SINK@ +10%; dunstify 'Vol' -h "
		  "int:value:$(pamixer --get-volume)");
	else if (strcmp("down", argv[2]) == 0)
	  system("pactl set-sink-volume @DEFAULT_SINK@ -10%; dunstify 'Vol' -h "
		  "int:value:$(pamixer --get-volume)");
	else if (strcmp("toggle", argv[2]) == 0)
	  system("pactl set-sink-mute@DEFAULT_SINK@ toggle  ; dunstify 'Mute' -h "
		  "int:value:$(pamixer --get-volume)");
	else
	  return 1;

  } else if (strcmp("mic", argv[1]) == 0) {
	if (strcmp("down", argv[2]) == 0)
	  system("pactl set-source-mute @DEFAULT_SOURCE@ toggle; dunstify 'Mic Mute' "
		  "-h int:value:$(pamixer --get-volume)");
	else
	  return 1;

  } else if (strcmp("light", argv[1]) == 0) {
	if (strcmp("up", argv[2]) == 0)
	  system("light -A 5; dunstify 'Light:' -h int:value:$(light)");
	else if (strcmp("down", argv[2]) == 0)
	  system("light -U 5; dunstify 'Light:' -h int:value:$(light)");
	else
	  return 1;

  } else if (strcmp("media", argv[1]) == 0) {
	if (strcmp("toggle", argv[2]) == 0)
	  system("playerctl play-pause; dunstify $(_tool_media_info)");
	else if (strcmp("next", argv[2]) == 0)
	  system("playerctl next; dunstify $(_tool_media_info)");
	else if (strcmp("prev", argv[2]) == 0)
	  system("playerctl previous; dunstify $(_tool_media_info)");
	else
	  return 1;
  } else
	return 1;

  return 0;
}
