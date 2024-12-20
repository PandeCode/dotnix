#!/bin/sh

# Default configurations
NIXOS_CONFIG=${2:-./#wslnix}
HOMEMANAGER_CONFIG=${3:-./#shawn@wslnix}

case "$1" in
  "n" | "no" | "nixos")
    echo "Switching to NixOS configuration..."
    sudo nixos-rebuild switch -v --flake "$NIXOS_CONFIG" --show-trace
    ;;
  "h" | "hm" | "home-manager")
    echo "Switching to Home Manager configuration..."
    home-manager switch -v --flake "$HOMEMANAGER_CONFIG"
    ;;
  "a" | "all")
    echo "Switching to both NixOS and Home Manager configurations..."
    sudo nixos-rebuild switch -v --flake "$NIXOS_CONFIG"
    home-manager switch -v --flake "$HOMEMANAGER_CONFIG"
    ;;
  *)
    echo "Usage: $0 {n | nixos [config] | h | home-manager [config] | a | all [nixos_config home-manager_config]}"
    exit 1
    ;;
esac
