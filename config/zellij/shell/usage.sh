#!/bin/sh

top -bn1 |
	grep 'Cpu(s)' |
	awk '{ per = 100 - $8 }
END {
if (per > 70) printf "#[fg=#ff5555]";
else if(per > 50) printf "#[fg=#f1fa8c]";
else printf "#[fg=#8F93A2]"}
END { printf per"%" }'
