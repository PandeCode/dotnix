#!/usr/bin/env bash

set -e

hash=$(date +'%Y-%m-%d-%H-%M-%S')
csoi > /tmp/image-$hash.png && feh /tmp/image-$hash.png &
echo /tmp/image-$hash.png | cs
notify-send "Clip image" "/tmp/image-$hash.png"
