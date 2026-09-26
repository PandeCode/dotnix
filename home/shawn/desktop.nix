{ pkgs, ... }:

let
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

{
  programs.alacritty.enable = true;

  home.packages = with pkgs; [
    (rofi.override {
      plugins = [
        rofi-calc
        rofi-emoji
        rofi-games
        rofi-mpd
        rofi-power-menu
      ];
    })
    rofi-bluetooth
    rofi-wifi-menu
  ];

  xdg.configFile."rofi/nix.rasi".source = ../../config/rofi/config.rasi;
}
