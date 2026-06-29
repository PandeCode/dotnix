{pkgs, ...}: {
  imports = [../wayland/os.nix];

  programs.sway = {
    package = pkgs.swayfx;
    enable = true;
    wrapperFeatures.gtk = true;
  };
}
