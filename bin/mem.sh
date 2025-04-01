#!/usr/bin/env bash

free -m |
	awk '/^Mem/ {per=int($3/$2*100)};
END {
	if (per > 70) printf "#ff5555 ";
	else if(per > 50) printf "#f1fa8 ";
	else printf "#8F93A2 "}
END {
	printf per
}
'
