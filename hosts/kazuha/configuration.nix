# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  config,
  pkgs,
  sharedConfig,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/hosts/default.nix
    ../../modules/gaming/os.nix

    ../../modules/wm/sddm.nix
    ../../modules/wm/plymouth.nix

    ../../modules/wm/hyprland/os.nix
    ../../modules/wm/sway/os.nix

    ../../modules/wm/awesomewm/os.nix
    ../../modules/wm/bspwm/os.nix
    ../../modules/wm/dwm/os.nix
    ../../modules/wm/i3/os.nix
    ../../modules/wm/xmonad/os.nix

    ../../modules/hosts/stylix.nix
  ];
  plymouth.enable = true;
  sddm.enable = true;

  hyprland.enable = sharedConfig.hyprland.enable;
  sway.enable = sharedConfig.sway.enable;

  awesomewm.enable = sharedConfig.awesomewm.enable;
  bspwm.enable = sharedConfig.bspwm.enable;
  dwm.enable = true;
  i3.enable = sharedConfig.i3.enable;
  xmonad.enable = sharedConfig.xmonad.enable;

  stylix_os = {
    enable = true;
    boot.enable = lib.mkForce true;
  };

  gaming_os.enable = false;

  zramSwap = {
    enable = true;
  };

  services = {
    # qemuGuest.enable = true;
    openssh.settings.PermitRootLogin = lib.mkForce "yes";
  };

  networking.hostName = "kazuha";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Costa_Rica";

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      # systemd-boot.enable = true;
      # systemd-boot.windows = {
      #   "11" = {
      #     title = "Windows 11";
      #     efiDeviceHandle = "/dev/nvme0n1p2";
      #   };
      # };
      grub = {
        enable = true;
        useOSProber = true;
        device = "nodev";
        efiSupport = true;
      };

      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CR.UTF-8";
    LC_IDENTIFICATION = "es_CR.UTF-8";
    LC_MEASUREMENT = "es_CR.UTF-8";
    LC_MONETARY = "es_CR.UTF-8";
    LC_NAME = "es_CR.UTF-8";
    LC_NUMERIC = "es_CR.UTF-8";
    LC_PAPER = "es_CR.UTF-8";
    LC_TELEPHONE = "es_CR.UTF-8";
    LC_TIME = "es_CR.UTF-8";
  };

  # services.printing.enable = true;

  users.users.shawn = {
    isNormalUser = true;
    description = "shawn";
    extraGroups = ["networkmanager" "wheel" "video"];
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11"; # Did you read the comment?

  programs.kdeconnect.enable = true;
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
