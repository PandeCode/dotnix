#!/usr/bin/env bash
hyprctl -q keyword animations:enabled true

hyprctl -q keyword unbind "ALT, tab"
hyprctl -q keyword bind ALT, tab, exec, "hyprctl -q keyword animations:enabled false ; hyprctl -q dispatch exec 'footclient -a alttab hypralttab.sh' ; hyprctl -q keyword unbind 'ALT, tab' ; hyprctl -q dispatch submap alttab"
