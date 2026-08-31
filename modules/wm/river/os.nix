{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../wayland/os.nix
  ];

  programs = {
    river-classic = {
      enable = true;
      package = pkgs.river;
    };
  };
}
