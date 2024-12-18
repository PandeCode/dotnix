#!/bin/sh

sudo nixos-rebuild switch  -v --flake .

# home-manager switch --log-format bar-with-logs -v --flake ./#nixos 
