{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotnix.profiles.security;
in

{
  options.dotnix.profiles.security.enable =
    lib.options.mkEnableOption "my sudo, polkit and pam rules";

  config = lib.modules.mkIf cfg.enable {
    security = {
      sudo = {
        enable = true;
        extraRules = [
          {
            groups = [ "wheel" ];
            commands =
              map
                (command: {
                  inherit command;
                  options = [ "NOPASSWD" ];
                })
                [
                  "${pkgs.systemd}/bin/systemctl suspend"
                  "${pkgs.systemd}/bin/systemctl hibernate"
                  "${pkgs.systemd}/bin/reboot"
                  "${pkgs.systemd}/bin/poweroff"
                  (lib.meta.getExe pkgs.systemctl-tui)
                ];
          }
        ];
        # timestamp_timeout=-1: asks once per terminal, never again
        extraConfig = ''
          Defaults timestamp_timeout=-1
          Defaults insults
          Defaults passwd_tries=5
        '';
      };

      polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users") && [
              "org.freedesktop.login1.power-off",
              "org.freedesktop.login1.power-off-multiple-sessions",
              "org.freedesktop.login1.reboot",
              "org.freedesktop.login1.reboot-multiple-sessions",
            ].indexOf(action.id) >= 0
          ) {
            return polkit.Result.YES;
          }
        });
      '';

      pam.services.sddm = lib.modules.mkIf config.services.displayManager.sddm.enable {
        enableGnomeKeyring = true;
        gnupg.enable = true;
      };

      pam.loginLimits = [
        {
          domain = "@users";
          item = "rtprio";
          type = "-";
          value = 1;
        }
      ];
    };
  };
}
