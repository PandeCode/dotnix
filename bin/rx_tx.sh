#!/usr/bin/env bash

awk '/wlp191s0/ {
  rx=$2; tx=$10;
  cmd="numfmt --to=iec --format=%.2f " rx;
  cmd2="numfmt --to=iec --format=%.2f " tx;
  cmd | getline rxmb; close(cmd);
  cmd2 | getline txmb; close(cmd2);
  print rxmb, txmb
}' /proc/net/dev
