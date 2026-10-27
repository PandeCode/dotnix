# flashing and debugging microcontrollers without root: st-link probes, the
# board's serial port and usb logic analyzers. the toolchains live in each
# project's flake
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotnix.profiles.embedded;
in

{
  options.dotnix.profiles.embedded.enable =
    lib.options.mkEnableOption "st-link probes, serial ports and logic analyzers";

  config = lib.modules.mkIf cfg.enable {
    services.udev.packages = with pkgs; [
      # keep-sorted start
      # 61-libsigrok-plugdev.rules hands analyzers to plugdev
      libsigrok
      # st-link v1 to v3, nucleo boards included
      stlink
      # keep-sorted end
    ];

    users.groups.plugdev = { };

    users.users.${config.dotnix.user}.extraGroups = [
      "dialout"
      "plugdev"
    ];

    # vendor tools like STM32CubeProgrammer ship prebuilt linux binaries
    programs.nix-ld.enable = true;
  };
}
