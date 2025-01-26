{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.gaming;
in {
  options.gaming = {
    enable = lib.mkEnableOption "Enable gaming packages and configuration.";

    epic = lib.mkEnableOption "Enable Heroic Games Launcher (Epic Games).";
    minecraft = lib.mkEnableOption "Enable Minecraft.";
    osu = lib.mkEnableOption "Enable osu!.";
    ps2 = lib.mkEnableOption "Enable ps2 emulation.";
    switch = lib.mkEnableOption "Enable Switch emulation.";
    wallpaperengine = lib.mkEnableOption "Enable Wallpaper Engine.";
    wii = lib.mkEnableOption "Enable Wii emulation.";
  };

  config = lib.mkIf (cfg.enable && osConfig.gaming_os.enable) {
    home.packages = with pkgs; let
      enable_if = var: list:
        if cfg.${var}
        then list
        else [];
      epic = [heroic];
      minecraft = [(prismlauncher.override {jdks = [temurin-jre-bin-8 temurin-jre-bin-17 temurin-jre-bin-21];})];
      osu = [osu-lazer-bin];
      ps2 = [pcsx2-bin];
      switch = [suyu];
      wallpaperengine = [linux-wallpaperengine];
      wii = [cemu dolphin-emu];
    in
      [
        lutris
        wine-staging

        mangohud
        gamescope
      ]
      ++ enable_if "minecraft" minecraft
      ++ enable_if "osu" osu
      ++ enable_if "wii" wii
      ++ enable_if "switch" switch
      ++ enable_if "ps2" ps2
      ++ enable_if "epic" epic
      ++ enable_if "wallpaperengine" wallpaperengine;
  };
}
