{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (lib.lists) optionals;

  cfg = osConfig.dotnix.profiles.gaming;
in

lib.modules.mkIf cfg.enable {
  services.linux-wallpaperengine.enable = cfg.wallpaperengine;

  home.packages =
    with pkgs;
    [
      antimicrox
      gamescope
      mangohud
      wine-staging
      winetricks
    ]
    ++ optionals cfg.epic [ heroic ]
    ++ optionals cfg.minecraft [
      (prismlauncher.override {
        jdks = [
          temurin-jre-bin-8
          temurin-jre-bin-17
          temurin-jre-bin-21
          temurin-jre-bin-25
        ];
      })
    ]
    ++ optionals cfg.osu [ osu-lazer-bin ]
    ++ optionals cfg.ps2 [ pcsx2 ]
    ++ optionals cfg.switch [ eden ]
    ++ optionals cfg.wii [
      cemu
      dolphin-emu
    ];
}
