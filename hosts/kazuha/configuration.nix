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

    ../../modules/wm/default.os.nix

    ../../modules/wm/sddm.nix
    ../../modules/wm/plymouth.nix

    ../../modules/hosts/stylix.nix

    ../../modules/hosts/virt_manager.nix
    ../../modules/hosts/osx-kvm.nix
  ];

  # gaming_os.enable = false;

  zramSwap.enable = true;

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
    extraGroups = ["networkmanager" "wheel" "video" "libvirtd"];
  };

  nixpkgs.config.allowUnfree = true;

  security = {
    sudo = {
      enable = true;
      extraRules = [
        {
          commands =
            map (command: {
              inherit command;
              options = ["NOPASSWD"];
            })
            [
              "${pkgs.systemd}/bin/systemctl suspend"
              "${pkgs.systemd}/bin/reboot"
              "${pkgs.systemd}/bin/poweroff"
            ];
          groups = ["wheel"];
        }
      ];
      extraConfig = with pkgs; ''
        Defaults timestamp_timeout=-1
        Defaults insults
        Defaults passwd_tries=5
        Defaults:picloud secure_path="${lib.makeBinPath [
          systemd
        ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
    pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3 fuse3];
    };
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11";

  programs.kdeconnect.enable = true;
  programs.localsend.enable = true;
  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #
  #   settings = {
  #     devices = {
  #       "device" = {id = "DEVICE-ID-GOES-HERE";};
  #       "chaos" = {id = "DEVICE-ID-GOES-HERE";};
  #     };
  #     folders = {
  #       "School" = {
  #         path = "/home/${sharedConfig.username}/Vaults/School";
  #         devices = ["device" "chaos"];
  #         ignorePerms = false;
  #       };
  #     };
  #   };
  # };
  # systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

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
