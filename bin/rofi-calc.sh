#!/usr/bin/env bash

rofi -theme /tmp/launcher.rasi -show calc -modi calc -no-show-match -no-sort -calc-command "echo -n '{result}' | cs"
