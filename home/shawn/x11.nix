{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

lib.modules.mkIf osConfig.dotnix.x11.enable {
  services.dunst = {
    enable = true;
    settings.global = {
      dmenu = "dmenu -p dunst:";
      browser = "xdg-open";
    };
  };

  home = {
    # caps lock is control, shift + caps lock is caps lock
    file.".Xmodmap".text = ''
      clear lock
      clear control
      add control = Caps_Lock Control_L Control_R
      keycode 66 = Control_L Caps_Lock NoSymbol NoSymbol
    '';

    packages = with pkgs; [
      boomer
      dmenu
      feh
      haskellPackages.greenclip
      libxcvt
      maim
      paperview
      picom-pijulius
      scrot
      slop
      xclip
      xcolor
      xdo
      xdotool
      xmenu
      xmodmap
      xtitle
      xwinwrap
    ];
  };

  xdg.configFile = {
    # linked, not copied: edit it in the repo and restart picom
    "picom/picom.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${osConfig.dotnix.flakePath}/config/picom/picom.conf";

    "greenclip.toml".text = ''
      [greenclip]
      history_file = "${config.xdg.cacheHome}/greenclip.history"
      max_history_length = 50
      max_selection_size_bytes = 0
      trim_space_from_selection = true
      use_primary_selection_as_input = false
      blacklisted_applications = []
      enable_image_support = true
      image_cache_directory = "/tmp/greenclip"
      static_history = []
    '';
  };
}
