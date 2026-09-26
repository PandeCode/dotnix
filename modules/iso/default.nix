# the live system with installer, filled in when the iso is built
{ modulesPath, ... }:

{
  imports = [
    ../nixos
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
}
