{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    light.enable = true;
  };

  # nixpkgs.config.permittedInsecurePackages = [
  # "adobe-reader-9.5.5"
  # ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [7000 7100 5900];
      allowedUDPPorts = [6000 6001 7011 5900];
      allowedTCPPortRanges = [
        {
          from = 30000;
          to = 60000;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 30000;
          to = 60000;
        }
      ];
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

  security.rtkit.enable = true;

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

  environment = {
    systemPackages = with pkgs; [
      dunst
      libnotify

      libreoffice-qt6

      cage

      mpv
      openshot-qt
      nautilus
      obsidian
      inkscape
      zathura
      # adobe-reader

      neovide

      anime4k
      miru
      hakuneko
      manga-tui
      comic-mandown

      linux-wifi-hotspot

      texliveFull
      # godot_4-mono
      godot_4
      pixelorama
      libresprite

      uxplay
      pandoc
      vesktop
      vscode
      google-chrome
      whatsapp-for-linux
      qbittorrent-enhanced-nox

      xwayland-satellite

      # inputs.zen-browser.packages."${system}".beta
      inputs.zen-browser.packages."${system}".twilight
      # inputs.zen-browser.packages."${system}".twilight-official

      gparted
      blueman
      networkmanager
      networkmanagerapplet
      pavucontrol

      gnome-clocks

      vlc
      sunshine
      android-tools
      scrcpy
    ];
  };
}
