{pkgs, ...}: {
  hardware.intel-gpu-tools.enable = true;

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
            (with pkgs; [
              "${systemd}/bin/systemctl suspend"
              "${systemd}/bin/systemctl hibernate"
              "${systemd}/bin/reboot"
              "${systemd}/bin/poweroff"
              # "${stacer}/bin/stacer"
              "${systemctl-tui}/bin/systemctl-tui"
              "${intel-gpu-tools}/bin/intel_gpu_top"
            ]);
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
      bash
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
