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
