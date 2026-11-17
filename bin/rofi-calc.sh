#!/usr/bin/env bash

rofi -theme /tmp/launcher.rasi \
	-show calc \
	-modi calc \
	-terse \
	-calc-command "echo -n '{result}' | cs"
