{
  lib,
  osConfig,
  pkgs,
  self,
  ...
}:

let
  inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) scripts;

  rofi = pkgs.symlinkJoin {
    name = "rofi";
    paths = [
      (pkgs.rofi.override {
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
          rofi-games
          rofi-mpd
          rofi-power-menu
        ];
      })
    ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # the theme follows the wallpaper, so it is made at runtime
    postBuild = ''
      wrapProgram $out/bin/rofi \
        --run '[ -f /tmp/launcher.rasi ] || ${scripts}/bin/rofi-make-config.sh >/dev/null' \
        --add-flags "-config ${../../config/rofi/config.rasi} -theme /tmp/launcher.rasi"
    '';
  };

  # installed from the fetched file, not read into nix, so evaluation does
  # not have to download it
  rofi-wifi-menu = pkgs.runCommandLocal "rofi-wifi-menu" { } ''
    install -Dm755 ${
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/zbaylin/rofi-wifi-menu/refs/heads/master/rofi-wifi-menu.sh";
        sha256 = "0gilv2q4l7synn1labwzw3bm4xy4h1z2l7kh1jhjyfxn3xpx7fnc";
      }
    } $out/bin/rofi-wifi-menu
    patchShebangs $out/bin
  '';
in

lib.modules.mkIf osConfig.dotnix.profiles.desktop.enable {
  programs.alacritty.enable = true;

  home.packages = [
    rofi
    rofi-wifi-menu
  ]
  ++ lib.lists.optional osConfig.services.blueman.enable pkgs.rofi-bluetooth;
}
