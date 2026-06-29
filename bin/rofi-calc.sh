#!/usr/bin/env bash

rofi -theme /tmp/launcher.rasi \
	-show calc \
	-modi calc \
	-calc-command "echo -n '{result}' | cs"
