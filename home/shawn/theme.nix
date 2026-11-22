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

  # gf2 wants bare hex
  s = config.lib.stylix.colors;
  gf2Theme = pkgs.writeText "gf2-theme.ini" (
    lib.generators.toINI { } {
      theme = {
        panel1 = s.base01;
        panel2 = s.base00;
        text = s.base05;
        textDisabled = s.base03;
        border = s.base02;
        buttonNormal = s.base02;
        buttonHovered = s.base03;
        buttonPressed = s.base00;
        buttonDisabled = s.base01;
        textboxNormal = s.base02;
        textboxFocused = s.base03;
        codeFocused = s.base02;
        codeBackground = s.base00;
        codeDefault = s.base05;
        codeComment = s.base04;
        codeString = s.base0B;
        codeNumber = s.base09;
        codeOperator = s.base0C;
        codePreprocessor = s.base0E;
        selected = s.base0D;
        textSelected = s.base00;
        # the status light, accent1 while running and accent2 when stopped
        accent1 = s.base08;
        accent2 = s.base0B;
      };
    }
    # blank line before whatever section comes next
    + "\n"
  );

  # gf2 writes trusted_folders into its config, so it can't be a store link.
  # swap in the theme section and leave the rest alone
  setGf2Theme = pkgs.writeShellScript "set-gf2-theme" ''
    ini=$HOME/.config/gf2_config.ini
    touch "$ini"
    {
      cat ${gf2Theme}
      ${lib.meta.getExe pkgs.gawk} '/^\[/ { skip = ($0 == "[theme]") } !skip' "$ini"
    } > "$ini.tmp"
    mv "$ini.tmp" "$ini"
  '';

  # config/tmux/.tmux.conf keeps these in place of its own when @theme is set
  tmuxColors = {
    bg = c.base00;
    surface = c.base01;
    line = c.base02;
    muted = c.base04;
    text = c.base05;
    bright = c.base07;
    normal = c.base0D;
    insert = c.base0B;
    visual = c.base0E;
    command = c.base0A;
    replace = c.base08;
    warn = c.base0A;
    error = c.base08;
  };
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

  home.activation.gf2Theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${setGf2Theme}
  '';

  # ahead of the source line in shell.nix
  home.file.".tmux.conf".text = lib.modules.mkBefore (
    lib.strings.concatLines (
      [ "set -g @theme stylix" ]
      ++ lib.attrsets.mapAttrsToList (role: color: ''set -g @c_${role} "${color}"'') tmuxColors
    )
  );

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
