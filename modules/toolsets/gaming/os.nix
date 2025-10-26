{pkgs, ...}: {
  hardware = {
    steam-hardware.enable = true;
    uinput.enable = true;
  };

  programs = {
    steam.enable = true;
    gamemode.enable = true;
  };

  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];
}
