{...}: let
in {
  imports = [../x/os.nix];
  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw
  services.xserver.windowManager.i3.enable = true;
}
