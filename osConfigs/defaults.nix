{
  git.user = {
    name = "PandeCode";
    email = "pandeshawnbenjamin@gmail.com";
  };

  terminal = "ghostty";
  explorer = "nautilus";
  browser = "zen";
  editor = "nvim";

  isLaptop = false;

  virt_manager.enable = false;
  osx-kvm.enable = false;

  wms = {
    hyprland.enable = false;
    sway.enable = false;
    i3.enable = true;
    dwm.enable = false;
    river.enable = false;
    niri.enable = true; # issue https://github.com/sodiboo/niri-flake/issues/1018
    # dwm.enable = true;
    # xmonad.enable = true;
    # bspwm.enable = true;
    # awesomewm.enable = true;
  };

  gaming = {
    enable = false;
    epic = false;
    minecraft = false;
    osu = false;
    ps2 = false;
    switch = false;
    wallpaperengine = false;
    wii = false;
  };
}
