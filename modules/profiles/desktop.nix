{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkDefault mkIf;

  cfg = config.dotnix.profiles.desktop;
  home = config.home-manager.users.${config.dotnix.user};
in

{
  options.dotnix.profiles.desktop.enable = lib.options.mkEnableOption "my desktop";

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };

      libinput = {
        enable = true;
        touchpad = {
          middleEmulation = true;
          disableWhileTyping = false;
          tapping = true;
          additionalOptions = ''
            Option "PalmDetection" "on"
            Option "TappingButtonMap" "lmr"
          '';
        };
      };

      blueman.enable = true;

      displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;
        wayland.enable = true;
        theme = "sddm-custom-theme";
        extraPackages = [ pkgs.sddm-custom-theme ];
      };
    };

    hardware.opentabletdriver.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          # battery levels of headsets; the arch wiki warns it can be buggy
          Experimental = true;
          # faster reconnects, costs some power
          FastConnectable = true;
        };
        Policy.AutoEnable = true;
      };
    };

    # media keys on bluetooth headsets
    systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = [
        "network.target"
        "sound.target"
      ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };

    boot = {
      plymouth = {
        enable = true;
        theme = "blahaj";
        themePackages = [ pkgs.plymouth-blahaj-theme ];
      };

      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
      loader.timeout = lib.modules.mkForce 4;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # screen sharing under river; the output is set per host
      wlr.settings.screencast = {
        max_fps = 30;
        exec_before = "disable_notifications.sh";
        exec_after = "enable_notifications.sh";
        chooser_type = "simple";
        chooser_cmd = "${lib.meta.getExe pkgs.slurp} -f 'Monitor: %o' -or";
      };
    };

    programs = {
      kdeconnect.enable = true;

      nautilus-open-any-terminal = {
        enable = true;
        inherit (home.dotnix.wm) terminal;
      };

      ydotool = mkIf config.dotnix.wayland.enable {
        enable = true;
        group = "users";
      };
    };

    environment = {
      sessionVariables.XKB_DEFAULT_OPTIONS = mkIf config.dotnix.wayland.enable "ctrl:nocaps,grp:win_space_toggle";

      systemPackages = with pkgs; [
        alsa-utils
        gparted
        libnotify
        linux-wifi-hotspot
        mesa-demos
        nautilus
        networkmanagerapplet
        pavucontrol
        pulseaudio
        sddm-custom-theme
        virtualglLib
        vulkan-tools
      ];
    };

    fonts.packages =
      (with pkgs; [
        fira-code
        fira-code-symbols
        libertinus
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ])
      ++ (with pkgs.nerd-fonts; [
        comic-shanns-mono
        dejavu-sans-mono
        fantasque-sans-mono
        fira-code
        fira-mono
        jetbrains-mono
      ]);

    dotnix.profiles.theme.enable = mkDefault true;
  };
}
