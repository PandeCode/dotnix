{
  pkgs,
  inputs,
  lib,
  ...
}: {
  # nixpkgs.config.permittedInsecurePackages = [
  # "adobe-reader-9.5.5"
  # ];

  xdg.portal.enable = lib.mkForce true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  security.rtkit.enable = true;

  # services.xserver.desktopManager.gnome.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # services.xserver.desktopManager.plasma6.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    libinput = {
      enable = true;
      touchpad = {
        middleEmulation = true;
        disableWhileTyping = true;
        tapping = true;

        additionalOptions = ''
          Option "PalmDetection" "on"
          Option "TappingButtonMap" "lmr"
        '';
      };
    };
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

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = sharedConfig.terminal;
  };

  environment = {
    systemPackages = with pkgs; [
      dunst
      libnotify

      onlyoffice-bin
      # libreoffice-qt6

      cage

      mpv
      # openshot-qt
      nautilus
      obsidian
      # inkscape
      zathura
      # adobe-reader

      neovide

      anime4k
      miru
      hakuneko
      manga-tui
      comic-mandown

      linux-wifi-hotspot

      typst
      vimb
      # texliveFull
      # godot_4-mono
      # godot_4
      # pixelorama
      # libresprite

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
      # sunshine
      # android-tools
      # scrcpy
    ];
  };
}
