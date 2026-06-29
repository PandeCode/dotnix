#!/usr/bin/env bash

ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ &&  print $1' | grep -v 127.0.0.1 | tr -d "\n"
