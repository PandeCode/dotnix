#!/usr/bin/env bash

free -m |
	awk '/^Mem/ {per=int($3/$2*100)};
END {
	if (per > 70) printf "#[fg=#ff5555]";
	else if(per > 50) printf "#[fg=#f1fa8]";
	else printf "#[fg=#8F93A2]"}
END {
	printf per "%"
}
'
