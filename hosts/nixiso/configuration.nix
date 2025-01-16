{
  inputs,
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/hosts/default.nix
    ../../modules/wm/hyprland/default.nix
    ../../modules/hosts/stylix.nix
  ];

  hyprland_os.enable = true;

  system.stateVersion = "24.05";

  stylix_os = {
    enable = true;
    boot.enable = lib.mkForce true;
  };

  # services = {
  # qemuGuest.enable = true;
  # openssh.settings.PermitRootLogin = lib.mkForce "yes";
  # };

  networking.hostName = "nixiso";
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  };
  time.timeZone = "America/Costa_Rica";

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3];
    };
  };

  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.users.nixos = import ../../homes/nixiso/home.nix;
  home-manager.useGlobalPkgs = true;
  users.extraUsers.root.password = "nixos";
}
