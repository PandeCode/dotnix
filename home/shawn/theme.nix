{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;

  bases = map (n: "base0${lib.strings.toUpper (lib.trivial.toHexString n)}") (lib.lists.range 0 15);
  colors = map (name: c.${name}) bases;
in

lib.modules.mkIf osConfig.dotnix.profiles.theme.enable {
  stylix = {
    enable = true;
    polarity = "dark";
    icons = {
      enable = true;
      package = pkgs.arc-icon-theme;
      dark = "Arc-Dark";
      light = "Arc";
    };

    targets = {
      # themed by hand
      rofi.enable = false;
      neovim.enable = false;

      librewolf.profileNames = [ "main" ];
    };
  };

  programs.newsboat.extraConfig = lib.modules.mkBefore "color background ${c.base00}";

  xdg.configFile = {
    "gowall/config.yml".text = builtins.toJSON {
      EnableImagePreviewing = false;
      themes = [
        {
          name = "nix";
          inherit colors;
        }
      ];
    };

    "stylix/font".text = config.stylix.fonts.sansSerif.name;

    "stylix/style.sh".text = lib.strings.concatLines (map (name: "export ${name}=${c.${name}}") bases);

    "stylix/style.scss".text = lib.strings.concatLines (map (name: "\$${name}: ${c.${name}};") bases);

    "stylix/style.lua".text = ''
      return {
      ${lib.strings.concatLines (map (name: "  ${name} = '${c.${name}}',") bases)}}
    '';
  };

  # stylix has no niri target (that came from niri-flake)
  dotnix.niri.settings.layout = {
    focus-ring = {
      active-color = c.base0D;
      inactive-color = c.base03;
    };
    border = {
      active-color = c.base0D;
      inactive-color = c.base03;
    };
  };
}
