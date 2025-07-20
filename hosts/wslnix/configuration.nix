{
  pkgs,
  lib,
  # nixpkgs-stable,
  # config, lib,  inputs, pkgs-unstable,
  ...
}:
# let stable = import nixpkgs-stable {}; in
{
  imports = [
    ../../modules/hosts/default.nix
    ../../modules/hosts/stylix.nix
  ];

  stylix_os = {
    enable = true;
    boot.enable = lib.mkForce false;
  };

  system.stateVersion = "24.05"; # IMPORTANT: NixOS-WSL breaks on other state versions
  networking.hostName = "wslnix";
  wsl = {
    enable = true;
    defaultUser = "shawn";
    wslConf.network.hostname = "wslnix";
  };

  # timezone = "Toronto/Canada";
  # timezone = "America/Costa_Rica";

  users.users.shawn = {
    isNormalUser = true;
    description = "shawn";
    extraGroups = ["networkmanager" "wheel"];
  };

  nix = {
    settings = {
      trusted-users = ["root" "shawn"];
    };
  };

  systemd.services."user-runtime-dir@" = {
    overrideStrategy = "asDropin";
    unitConfig.ConditionPathExists = "!/run/user/%i";
  };
}
