#!/usr/bin/env bash
curl "https://duckduckgo.com/ac/?q=$1" -s | jq -r '.[] .phrase'
