{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    ../wayland/os.nix
  ];

  programs = {
    river = {
      enable = true;
    };
  };
  environment = {
    systemPackages = [
    ];
  };
}
