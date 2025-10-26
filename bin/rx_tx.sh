#!/usr/bin/env bash

awk '/wlo1/ {print $2 " " $10 }' /proc/net/dev
