{
  pkgs,
  lib,
  config,
  ...
}:
with builtins;
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
  options.i3.enable = lib.mkEnableOption "enable i3";

  config = lib.mkIf cfg.enable {
    x.enable = true;

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      config = rec {
        window.titlebar = false;
        modifier = "Mod4";
        terminal = "wezterm";
        keybindings =
          flattenListAttrsToAttr
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
  };
}
