{
  pkgs,
  sharedConfig,
  ...
}: {
  services = {
    arrpc.enable = false;
    linux-wallpaperengine =
      if sharedConfig.gaming.wallpaperengine
      then {
        enable = true;
      }
      else {};
  };
  home.packages = with pkgs; let
    enable_if = var: list:
      if sharedConfig.gaming.${var}
      then list
      else [];

    epic = [heroic];
    minecraft = [(prismlauncher.override {jdks = [temurin-jre-bin-8 temurin-jre-bin-17 temurin-jre-bin-21];})];
    # minecraft = [ prismlauncher ];
    osu = [osu-lazer-bin];
    ps2 = [pcsx2-bin];
    switch = [suyu];
    wallpaperengine = [linux-wallpaperengine];
    wii = [cemu dolphin-emu];
  in
    [
      lutris
      wine-staging
      winetricks

      antimicrox
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
}
