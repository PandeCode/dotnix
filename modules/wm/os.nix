{
  pkgs,
  inputs,
  lib,
  sharedConfig,
  ...
}: {
  # nixpkgs.config.permittedInsecurePackages = [
  # "adobe-reader-9.5.5"
  # ];

  xdg.portal.enable = lib.mkForce true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  imports = [inputs.aagl.nixosModules.default];
  programs.honkers-railway-launcher.enable = false;

  security.rtkit.enable = true;

  virtualisation.docker = {
    # enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

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
    inherit (sharedConfig) terminal;
  };

  environment = {
    systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools

      freerdp

      libnotify

      onlyoffice-desktopeditors
      # libreoffice-qt6

      cage

      mpv
      # openshot-qt
      nautilus
      obsidian
      rnote
      # inkscape
      zathura
      # adobe-reader

      neovide

      anime4k
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
