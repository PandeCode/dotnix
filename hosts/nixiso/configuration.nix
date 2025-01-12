{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/hosts/default.nix
    ../../modules/desktop_env/hyprland.nix
    ../../modules/hosts/stylix.nix
  ];

  stylix_os = {
    enable = true;
    boot.enable = lib.mkForce true;
  };

  system.stateVersion = "24.05";

  networking.hostName = "nixiso";
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  # timezone = "America/Costa_Rica";

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3];
    };
  };
}
