{ config, ... }:

let
  inherit (config.dotnix) user;
in

{
  # more groups come with the modules that need them (docker, libvirtd, ...)
  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [
      "input"
      "networkmanager"
      "video"
      "wheel"
    ];
  };
}
