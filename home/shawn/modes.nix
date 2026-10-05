{
  lib,
  osConfig,
  pkgs,
  ...
}:

lib.modules.mkIf osConfig.dotnix.profiles.desktop.enable {
  dotnix.modes.presentation = {
    # a plain font for people who aren't used to opendyslexic
    config.stylix.fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
    };

    # no popups on the projector; rofi remakes its theme with the new font
    on = ''
      disable_notifications.sh
      rm -f /tmp/launcher.rasi
    '';
    off = ''
      enable_notifications.sh
      rm -f /tmp/launcher.rasi
    '';
  };
}
