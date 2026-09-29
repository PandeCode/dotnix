# my live system: kazuha's desktop and tools on any machine, plus
# dotnix-install
{
  dotnix = {
    user = "shawn";

    profiles = {
      base.enable = true;
      desktop.enable = true;
    };
  };

  # the language tools of the full profiles would double the image
  programs = {
    hermes.profile = "minimal";
    libys.profile = "minimal";
  };

  # x11 is the safest bet on a GPU without its driver
  services.displayManager.defaultSession = "none+i3";
}
