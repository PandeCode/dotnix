{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../wayland/os.nix
    inputs.niri.nixosModules.niri
  ];

  nixpkgs.overlays = [inputs.niri.overlays.niri];

  systemd.user.services.niri-flake-polkit.enable = false;

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
}
