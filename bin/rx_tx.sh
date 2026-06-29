#!/usr/bin/env bash

awk '/wlo1/ {print ( $2 / 1000000 ) " " ( $10 / 100000 ) }' /proc/net/dev
