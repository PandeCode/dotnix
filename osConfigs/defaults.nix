{
  terminal = "kitty";
  explorer = "nautilus";

  gaming = {
    enable = true;
    epic = true;
    minecraft = true;
    osu = false;
    ps2 = false;
    switch = false;
    wallpaperengine = false;
    wii = false;
  };

  virt_manager.enable = false;
  osx-kvm.enable = false;

  wms = {
    hyprland.enable = false;
    sway.enable = true;
    i3.enable = true;
    dwm.enable = true;
    river.enable = false;
    niri.enable = false; # issue https://github.com/sodiboo/niri-flake/issues/1018
    # dwm.enable = true;
    # xmonad.enable = true;
    # bspwm.enable = true;
    # awesomewm.enable = true;
  };
}
