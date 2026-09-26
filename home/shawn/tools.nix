{
  pkgs,
  self,
  ...
}:

let
  inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) c-tools scripts;

  tool =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./scripts/${name}.sh;
    };
in

{
  home.packages = with pkgs; [
    c-tools
    scripts

    (tool "display-scale" [
      gawk
      jq
      wlr-randr
      xrandr
    ])

    (tool "lock" [
      hyprlock
      i3lock
      procps
      scripts
    ])

    (tool "record" [
      coreutils
      ffmpeg
      gawk
      jq
      libnotify
      procps
      slop
      slurp
      wf-recorder
      wl-clipboard
      wlr-randr
      xclip
      xdpyinfo
    ])

    (tool "screenshot" [
      coreutils
      grim
      libnotify
      maim
      slurp
      wl-clipboard
      xclip
    ])
  ];
}
