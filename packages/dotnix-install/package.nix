{
  lib,
  writeShellApplication,
  coreutils,
  findutils,
  gawk,
  git,
  gnused,
  gum,
  nixos-install-tools,
  util-linux,
}:

writeShellApplication {
  name = "dotnix-install";

  runtimeInputs = [
    coreutils
    findutils
    gawk
    git
    gnused
    gum
    nixos-install-tools
    util-linux
  ];

  runtimeEnv.HOST_TEMPLATE = ./host.nix;

  text = builtins.readFile ./dotnix-install.sh;

  meta = {
    description = "Install one of my machines, a new one, or stock NixOS";
    platforms = lib.platforms.linux;
  };
}
