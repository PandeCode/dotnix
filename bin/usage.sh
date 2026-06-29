#!/usr/bin/env bash

top -bn1 |
	grep 'Cpu(s)' |
	awk '{ per = 100 - $8 }
END {
if (per > 70) printf "#ff5555 ";
else if(per > 50) printf "#f1fa8c ";
else printf "#8F93A2 "}
END { printf per }'
