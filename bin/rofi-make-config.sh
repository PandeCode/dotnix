#!/usr/bin/env bash

# shellcheck disable=SC1091 # code is irrelevant because reasons

image=$(wall get-last)
font=$(cat ~/.config/stylix/font)

source "$HOME/.config/stylix/style.sh"

base00="${base00:-#000000}"
base01="${base01:-#1c1f24}"
base02="${base02:-#2c313a}"
base04="${base04:-#565c64}"
base05="${base05:-#abb2bf}"
base07="${base07:-#c8ccd4}"
base0B="${base0B:-#89ca78}"
base0D="${base0D:-#61afef}"
base0E="${base0E:-#d55fde}"

# laid out like an nvim window: modes in the tabline, the list as the
# completion menu, then the statusline and the command line
cat <<EOF >/tmp/launcher.rasi
configuration {
  font: "$font 12";
  modi: "drun,run,filebrowser,window,calc";
}

* {
  border: 0;
  margin: 0;
  padding: 0;
  spacing: 0;

  bg: $base00;
  panel: $base01;
  line: $base02;
  dim: $base04;
  fg: $base05;
  fg-alt: $base07;
  insert: $base0B;
  accent: $base0D;
  colon: $base0E;

  background-color: transparent;
  text-color: @fg;
}

window {
  transparency: "real";
  width: 760px;
  background-color: @bg;
  border: 1px;
  border-color: @line;
  border-radius: 6px;
}

mainbox {
  children: [tabline, message, listview, statusline, cmdline];
}

tabline {
  expand: false;
  orientation: horizontal;
  background-color: @panel;
  children: [mode-switcher, wallpaper];
}

mode-switcher {
  expand: false;
}

button {
  expand: false;
  padding: 6px 16px;
  text-color: @dim;
  background-color: @panel;
}

button selected {
  text-color: @bg;
  background-color: @accent;
}

wallpaper {
  background-image: url("$image", width);
}

message {
  padding: 8px 14px;
  background-color: @panel;
  border: 1px 0 0 0;
  border-color: @line;
}

textbox {
  text-color: @accent;
}

listview {
  lines: 8;
  padding: 6px 0;
  fixed-height: true;
  scrollbar: true;
}

scrollbar {
  handle-width: 4px;
  handle-color: @line;
}

element {
  padding: 4px 14px;
  spacing: 12px;
}

element selected.normal {
  background-color: @line;
}

element-icon {
  size: 22px;
}

element-text {
  vertical-align: 0.5;
}

element-text selected {
  text-color: @fg-alt;
}

statusline {
  expand: false;
  orientation: horizontal;
  background-color: @panel;
  children: [textbox-mode, prompt, fill, num-filtered-rows, textbox-slash, num-rows];
}

textbox-mode {
  expand: false;
  content: " INSERT ";
  padding: 3px 6px;
  text-color: @bg;
  background-color: @insert;
}

prompt {
  padding: 3px 10px;
}

num-filtered-rows, textbox-slash, num-rows {
  expand: false;
  padding: 3px 0;
  text-color: @dim;
}

textbox-slash {
  content: "/";
}

num-rows {
  padding: 3px 12px 3px 0;
}

cmdline {
  expand: false;
  orientation: horizontal;
  padding: 8px 12px;
  children: [textbox-colon, entry];
}

textbox-colon {
  expand: false;
  content: ":";
  padding: 0 6px 0 0;
  text-color: @colon;
}

entry {
  text-color: @fg-alt;
  cursor-color: @insert;
  cursor-width: 2px;
}
EOF

echo /tmp/launcher.rasi
