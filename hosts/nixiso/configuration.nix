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

    ../../modules/wm/default.nix
    ../../modules/wm/sddm.nix
    ../../modules/wm/plymouth.nix
    ../../modules/wm/hyprland/os.nix

    ../../modules/hosts/stylix.nix
  ];

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

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.nixos = import ../../homes/nixiso/home.nix;
    useGlobalPkgs = true;
  };
  users.extraUsers.root.password = "nixos";
}
