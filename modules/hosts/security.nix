{pkgs, ...}: {
  security = {
    sudo = {
      enable = true;
      extraRules = [
        {
          commands =
            map (command: {
              inherit command;
              options = ["NOPASSWD"];
            })
            [
              "${pkgs.systemd}/bin/systemctl suspend"
              "${pkgs.systemd}/bin/systemctl hibernate"
              "${pkgs.systemd}/bin/reboot"
              "${pkgs.stacer}/bin/stacer"
              "${pkgs.systemd}/bin/poweroff"
            ];
          groups = ["wheel"];
        }
      ];
      extraConfig = with pkgs; ''
        Defaults timestamp_timeout=-1
        Defaults insults
        Defaults passwd_tries=5
        Defaults:picloud secure_path="${lib.makeBinPath [
          systemd
        ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
    pam = {
      services.astal-auth = {};
      loginLimits = [
        {
          domain = "@users";
          item = "rtprio";
          type = "-";
          value = 1;
        }
      ];
    };

    polkit.extraConfig =
      /*
      js
      */
      ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users")
              && (
                action.id == "org.freedesktop.login1.reboot" ||
                action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                action.id == "org.freedesktop.login1.power-off" ||
                action.id == "org.freedesktop.login1.power-off-multiple-sessions"
              )
            )
          {
            return polkit.Result.YES;
          }
        });
      '';
  };
}
