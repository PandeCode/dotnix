{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.sddm;
  # image = pkgs.fetchurl {
  #   url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_bridge_with_lights_on_it.jpg";
  #   sha256 = "465390cba5d4fa1861f2948b59fabe399bd2d7d53ddd6c896b0739bee4eca2c8";
  # };
  # theme = pkgs.stdenv.mkDerivation {
  #   name = "sddm-theme";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "MarianArlt";
  #     repo = "sddm-sugar-dark";
  #     rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
  #     sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
  #   };
  #   installPhase = ''
  #     mkdir -p $out
  #     cp -R ./* $out/
  #     cd $out/
  #     rm Background.jpg
  #     cp -r ${image} $out/Background.jpg
  #   '';
  # };
in {
  options.sddm.enable = lib.mkEnableOption "enable sddm";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [catppuccin-sddm-corners];
    services.displayManager = {
      sddm = {
        theme = "catppuccin-sddm-corners";
        wayland.enable = true;
        enable = true;
      };
    };
  };
}
