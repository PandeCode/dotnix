{
  pkgs,
  lib,
  config,
  utils,
  ...
}:
with builtins;
with uilts;
with lib; let
  cfg = config.i3;

  flattenListAttrsToAttr = lib.foldl' (a: b: a // b) {};
  _ = {
    mod,
    key,
    exec,
  }: {
    "${(replaceStrings [" " "super" "alt"] ["+" "Mod4" "Mod1"] (trim "${mod} ${key}"))}" = "exec ${exec}";
  };
  mapBindingsToi3 = map _;
in {
  imports = [../x/home.nix];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = rec {
      window.titlebar = false;
      modifier = "Mod4";
      terminal = "wezterm";
      keybindings =
        {
          "Mod1+F4" = "kill";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+Shift+f" = "floating toggle";
        }
        // flattenListAttrsToAttr
        (
          (genList (
              j: let
                i = toString (j + 1);
              in {
                "Mod4+${i}" = "workspace number ${i}";
                "Mod4+shift+${i}" = "move container to workspace number ${i}";
              }
            )
            9)
          ++ (mapBindingsToi3 (config.x.shared.bindexec ++ config.x.shared.bindexec_el))
        );

      startup =
        map (command: {inherit command;}) config.x.shared.startup;
    };
  };
}
