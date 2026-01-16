{
  pkgs,
  # sharedConfig,
  ...
}: {
  hardware = {
    steam-hardware.enable = true;
    # openrazer = {
    #   enable = true;
    #   users = [sharedConfig.user];
    # }; # idk where to put it
    uinput.enable = true;
  };

  # environment.systemPackages = with pkgs; [
  #   razer-cli
  #   razergenie
  # ];

  programs = {
    steam.enable = true;
    gamemode.enable = true;
  };

  services = {
    input-remapper.enable = true;
    udev.packages = [
      pkgs.game-devices-udev-rules
    ];
  };
}
