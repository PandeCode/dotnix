{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.wm;
in {
  imports = [];

  options.wm.enable = lib.mkEnableOption "enable wm";

  config = lib.mkIf cfg.enable {
    programs = {
      light.enable = true;
      # kitty.enable = true;
      # alacritty.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        dunst
        libnotify

        libreoffice-qt6

        cage

        mpv
        nautilus
        obsidian
        pandoc
        vesktop
        vscodium
        google-chrome
        whatsapp-for-linux
        qbittorrent-enhanced-nox

        inputs.zen-browser.packages."${system}".default

        gparted
        blueman
        networkmanager
        networkmanagerapplet
        pavucontrol

        gnome-clocks

        vlc
        sunshine
      ];
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

    networking = {
      firewall = {
        enable = true;
      };
      # networkmanager = {
      #   enable = true;
      #   dns = "none";
      #   # wifi.powersave = true;
      # };

      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
    # users.users.<name>.extraGroups = [ "networkmanager" ];

    security.rtkit.enable = true;
    # services.pulseaudio = {
    #   enable = true;
    #   package = pkgs.pulseaudioFull;
    #   extraConfig = "load-module module-switch-on-connect";
    # };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            # Experimental = true; # Show battery # WARN: Arch Wiki warns for bugs
          };
        };
      };
    };

    # enable headset control for bluetooth headsets
    systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = ["network.target" "sound.target"];
      wantedBy = ["default.target"];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
  };
}
