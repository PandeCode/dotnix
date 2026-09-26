{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption;

  cfg = config.dotnix.profiles.gaming;
in

{
  # the launchers and emulators install in the home; these pick which
  options.dotnix.profiles.gaming = {
    enable = mkEnableOption "steam, controllers and game tools";
    epic = mkEnableOption "heroic";
    minecraft = mkEnableOption "prismlauncher";
    osu = mkEnableOption "osu!lazer";
    ps2 = mkEnableOption "pcsx2";
    switch = mkEnableOption "eden";
    wallpaperengine = mkEnableOption "linux-wallpaperengine";
    wii = mkEnableOption "cemu and dolphin";
  };

  config = lib.modules.mkIf cfg.enable {
    programs = {
      steam.enable = true;
      gamemode.enable = true;
    };

    hardware = {
      steam-hardware.enable = true;
      uinput.enable = true;
      openrazer = {
        enable = true;
        users = [ config.dotnix.user ];
      };
    };

    services = {
      input-remapper.enable = true;
      udev.packages = [ pkgs.game-devices-udev-rules ];
    };

    users.users.${config.dotnix.user}.extraGroups = [ "uinput" ];

    environment.systemPackages = with pkgs; [
      razer-cli
      razergenie
    ];
  };
}
