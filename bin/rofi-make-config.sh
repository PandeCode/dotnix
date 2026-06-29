#!/usr/bin/env bash

# shellcheck disable=SC1091 # code is irrelevant because reasons

image=$(bg.sh get-last)
font=$(cat ~/.config/stylix/font)

source "$HOME/.config/stylix/style.sh"

base01="${base01:-#1c1f24}"
base02="${base02:-#2c313a}"
base05="${base05:-#abb2bf}"
base07="${base07:-#c8ccd4}"
base0A="${base0A:-#e5c07b}"
base0D="${base0D:-#61afef}"

cat <<EOF >/tmp/launcher.rasi
configuration {
  font: "$font";
  modi: "drun,run,filebrowser,window,calc";
}

* {
  border: 0;
  margin: 0;
  padding: 0;
  spacing: 0;

  bg: $base01;
  bg-alt: $base02;
  fg: $base05;
  fg-alt: $base07;
  accent: $base0D;
  active: $base0A;

  background-color: @bg;
  text-color: @fg;
}

window {
  transparency: "real";
  width: 900px;
  border: 2px;
  border-color: @accent;
  border-radius: 12px;
}

mainbox {
  children: [imagebox, listbox];
  orientation: horizontal;
}

imagebox {
  padding: 20px;
  background-color: transparent;
  background-image: url("$image", height);
  orientation: vertical;
  children: [inputbar];
}

listbox {
  padding: 20px;
  background-color: transparent;
  orientation: vertical;
  children: [message, listview];
}

message {
  background-color: transparent;
  padding: 0px 0px 10px 0px;
}

textbox {
  background-color: @bg-alt;
  text-color: @accent;
  padding: 15px;
  border-radius: 8px;
}

inputbar {
  background-color: @bg-alt;
  children: [prompt, entry];
  border-radius: 8px;
}

entry {
  background-color: inherit;
  padding: 12px 3px;
  text-color: @fg-alt;
}

prompt {
  background-color: inherit;
  padding: 12px;
  text-color: @accent;
}

listview {
  lines: 8;
  padding: 0px;
}

element {
  children: [element-icon, element-text];
  border-radius: 8px;
  padding: 8px;
}

element selected {
  background-color: @bg-alt;
}

element-icon {
  padding: 0px 10px;
  size: 20px;
  background-color: transparent;
}

element-text {
  padding: 0px 0px;
  background-color: transparent;
}

element-text selected {
  text-color: @accent;
}
EOF

echo /tmp/launcher.rasi
