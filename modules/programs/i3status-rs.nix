{
  # pkgs,
  # lib,
  config,
  ...
}: let
  c = config.lib.stylix.colors;
  default = ''
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
    # separator = ""
    # end_separator = ""

    [icons]
    icons            = "awesome6"
    [icons.overrides]
    ban              = "\uf05e" # fa-ban
    wifi             = "\uf1eb" # fa-wifi
    signal           = "\uf012" # fa-signal
    exchange         = "\uf362" # fa-exchange-alt
    tachometer       = "\uf0e4" # fa-tachometer
    volume_empty     = "\ue04e" # volume_mute
    volume_full      = "\ue050" # volume_up
    volume_half      = "\ue04d" # volume_down
    volume_muted     = "\ue04f" # volume_off
    microphone_full  = "\ue029" # mic
    microphone_half  = "\ue029" # mic
    microphone_empty = "\ue02a" # mic_none
    microphone_muted = "\ue02b" # mic_off

  '';
in {
  xdg.configFile = {
    "i3status-rs/xconfig.toml".text = ''
      ${default}
      ${builtins.readFile ../../config/i3status-rs/xconfig.toml}
      ${builtins.readFile ../../config/i3status-rs/config.toml}
    '';
    "i3status-rs/wayconfig.toml".text = ''
      ${default}
      ${builtins.readFile ../../config/i3status-rs/wayconfig.toml}
      ${builtins.readFile ../../config/i3status-rs/config.toml}
    '';
  };
}
