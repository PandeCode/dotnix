#!/usr/bin/env bash

sed_expr="s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g"

cava -p <(cat <<EOF
[general]
bars = 12
sleep_timer = 10

[input]
method = pulse

[output]
method = raw
data_format = ascii
ascii_max_range = 6
EOF
) \
| sed -u -e "s/;//g;$sed_expr" \
        -e '/^▁\{12\}$/d'
