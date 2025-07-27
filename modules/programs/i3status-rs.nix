{
  # pkgs,
  # lib,
  config,
  ...
}: let
  c = config.lib.stylix.colors;
in {
  xdg.configFile."i3status-rs/config.toml".text = ''
    [theme.overrides]
    idle_bg = "#${c.base00}"      # Dark background
    idle_fg = "#${c.base05}"      # Default text

    good_bg = "#${c.base00}"
    good_fg = "#${c.base0B}"      # Green for "good"

    warning_bg = "#${c.base00}"
    warning_fg = "#${c.base0A}"   # Yellow/cyan for "warning"

    critical_bg = "#${c.base00}"
    critical_fg = "#${c.base0F}"  # Pink/red for "critical"

    info_bg = "#${c.base00}"
    info_fg = "#${c.base0D}"      # Blue/cyan for "info"

    alternating_tint_bg = "#${c.base01}"  # Slightly different dark
    alternating_tint_fg = "#${c.base05}"  # Normal text

    separator_bg = "#${c.base00}"
    separator = ""
    end_separator = ""


    ${builtins.readFile ../../config/i3status-rs/config.toml}
  '';
}
