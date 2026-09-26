# one screenshot command for every session, bound in wm.nix
{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "screenshot";
      runtimeInputs = with pkgs; [
        coreutils
        grim
        libnotify
        maim
        slurp
        wl-clipboard
        xclip
      ];
      text = builtins.readFile ./scripts/screenshot.sh;
    })
  ];
}
