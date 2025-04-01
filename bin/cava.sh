#!/usr/bin/env bash

# Define character sets
chars1='▁▂▃▄▅▆▇█'
chars2='⠁⠃⠇⡆⡇⣇⣧⣿'
chars3=' .:-=+*#%'
chars4=' ▏▎▍▌▋▊▉█'

default=$chars1

# Select character set based on argument
case "$1" in
    "set1")
        chars="$chars1"
        ;;
    "set2")
        chars="$chars2"
        ;;
    "set3")
        chars="$chars3"
        ;;
    "set4")
        chars="$chars4"
        ;;
    *)
        chars="$default"
        ;;
esac

# Convert characters to sed expression
sed_expr=$(echo "$chars" | awk '{for(i=0;i<length;i++) printf "s/%d/%s/g;", i, substr($0,i+1,1)}')

# Run cava with the selected character set
cava -p ~/.config/cava/shell | sed -u "s/;//g;$sed_expr"
