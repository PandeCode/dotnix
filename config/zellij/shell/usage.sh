#!/bin/sh

top -bn1 |
	grep 'Cpu(s)' |
	sed 's/.*, *\([0-9.]*\)%* id.*/\1/' |
	awk '{ per = 100 - $1 }
END {
if (per > 70) printf "#[fg=#ff5555]";
else if(per > 50) printf "#[fg=#f1fa8c]";
else printf "#[fg=#8F93A2]"}
END { printf per"%" }'
