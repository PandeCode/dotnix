#!/usr/bin/env bash

SPLASH=~/dotnix-media/bootanimations/vanilla.mp4

if [ -f $SPLASH ]; then
	mpv --fullscreen \
		--no-input-default-bindings \
	    --player-operation-mode=pseudo-gui \
		--no-config \
		--on-all-workspaces \
		$SPLASH &
fi
