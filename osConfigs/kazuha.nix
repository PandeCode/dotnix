(import ./defaults.nix)
// rec {
  hostName = "kazuha";
  hostname = hostName;

  user = "shawn";
  username = user;

  isLaptop = true;

  gaming = {
    enable = true;
    epic = true;
    minecraft = true;
    osu = false;
    ps2 = false;
    switch = false;
    wallpaperengine = true;
    wii = false;
  };

  resolution = {
    x = 1920;
    y = 1080;
  };
}
