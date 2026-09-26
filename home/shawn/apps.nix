{
  config,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.wm) terminal;

  # file choosers hand over file:// urls, and sometimes a file instead of
  # its directory
  open-tui = pkgs.writeShellApplication {
    name = "open-tui";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      tool=$1
      location=''${2#"file://"}
      if [[ ! -e $location ]]; then
        location=$(dirname "$location")
      fi
      exec ${terminal} -e "$tool" "$location"
    '';
  };

  inTerminal = name: command: {
    inherit name;
    exec = ''${terminal} --title="${name}" -e ${command}'';
    icon = "utilities-terminal";
    terminal = false;
    type = "Application";
    categories = [
      "System"
      "Utility"
    ];
  };
in

{
  programs = {
    vesktop = {
      enable = true;
      settings = {
        appBadge = false;
        arRPC = true;
        checkUpdates = false;
        customTitleBar = false;
        disableMinSize = true;
        discordBranch = "stable";
        hardwareAcceleration = true;
        minimizeToTray = false;
        splashBackground = "#000000";
        splashColor = "#ffffff";
        splashTheming = true;
        staticTitle = true;
        tray = false;
      };
    };

    distrobox = {
      enable = true;
      containers = {
        common-debian = {
          image = "debian:13";
          additional_packages = "git";
          entry = true;
          init_hooks = [
            "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
            "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
          ];
        };
        random-things = {
          clone = "common-debian";
          entry = false;
        };
      };
    };

    lf.enable = true;
    ranger.enable = true;
    xplr.enable = true;
    zathura.enable = true;
  };

  services.kdeconnect.enable = true;

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
        "image/png" = "feh.desktop";
        "inode/directory" = "xranger.desktop";
      };
    };

    desktopEntries = {
      xranger = {
        name = "xranger";
        genericName = "File Manager";
        exec = "${open-tui}/bin/open-tui ranger %F";
        icon = "utilities-terminal";
        terminal = false;
        type = "Application";
        categories = [
          "System"
          "FileTools"
          "FileManager"
        ];
        mimeType = [ "inode/directory" ];
        startupNotify = true;
      };

      systemctl-tui = inTerminal "Systemctl TUI" "systemctl-tui";
      systemctl-tui-sudo = inTerminal "Systemctl TUI (sudo)" ''bash -c "sudo systemctl-tui"'';
    };
  };

  home.packages = with pkgs; [
    # keep-sorted start
    (tesseract.override { enableLanguages = [ "eng" ]; })
    cage
    comic-mandown
    dejsonlz4
    freerdp
    gnome-clocks
    gram
    manga-tui
    ncdu
    neovide
    nix-search-cli
    notify-send-py
    obsidian
    onlyoffice-desktopeditors
    pandoc
    proselint
    pscircle
    qbittorrent-enhanced-nox
    rnote
    signal-desktop
    silicon
    sqlite
    statix
    typst
    vimb
    vscodium
    webex
    xdg-utils
    zoom-us
    zulip
    # keep-sorted end
  ];
}
