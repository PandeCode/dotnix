#!/usr/bin/env bash

find . -name core\* -user $USER -type f -size +1000000c -exec file {} \; -exec ls -l {} \; -exec printf "\n\ny to remove this core file\n" \; -exec /bin/rm -i {} \;
