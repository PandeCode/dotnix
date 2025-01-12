{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.hacking;
in {
  options.hacking = {
    enable = lib.mkEnableOption "enable hacking tools";
    qemu.enable = lib.mkEnableOption "enable qemu_full (large size)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        whois
        holehe
        lemmeknow
        nmap
        rustscan
        rustcat
        binwalk
        aircrack-ng
        john
        sshs

        nasm
        radare2
        aflplusplus
        pwntools
        legba

        # https://www.blackarch.org/tools.html
      ]
      ++ (
        if cfg.qemu.enable
        then [qemu_full]
        else []
      );
  };
}
