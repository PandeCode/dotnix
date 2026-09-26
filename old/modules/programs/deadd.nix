{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.deadd;
in {
  options.deadd.enable = lib.mkEnableOption "enable deadd";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.deadd-notification-center];

    xdg.configFile."deadd/deadd.yml".text =
      # yaml
      ''
        notification:
            modifications:
            - match:
                app-name: "Spotify"
              modify:
                class-name: "Spotify"
      '';
    # lib.strings.toJSON {
    # };

    xdg.configFile."deadd/deadd.css".text = ''
      .notificationInCenter.Spotify {
      	background: linear-gradient(130deg, rgba(0, 0, 0, 0.1), rgba(0, 255, 0, 0.3));
      	border-radius: 5px;
      }
    '';

    # services.deadd-notification-center = {

    # }
  };
}
