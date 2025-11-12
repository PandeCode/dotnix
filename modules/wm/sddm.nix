{pkgs, ...}: let
  sddm-custom-theme = pkgs.callPackage ../../derivations/sddm-custom-theme.nix {};
in {
  environment.systemPackages = [sddm-custom-theme];
  services = {
    xserver.enable = true;

    displayManager = {
      sddm = {
        wayland.enable = true;
        enable = true;
        package = pkgs.kdePackages.sddm;

        theme = "sddm-custom-theme";
        extraPackages = [
          sddm-custom-theme
        ];
      };
      autoLogin = {
        enable = false;
        user = "shawn";
      };
    };
  };
}
