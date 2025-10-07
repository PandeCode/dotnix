#!/usr/bin/env bash

find ~/Pictures/gifs/ -type f | shuf -n 1 | xargs -I{} pqiv -c -c -i '{}'
