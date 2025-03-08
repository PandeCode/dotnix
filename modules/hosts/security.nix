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
              "${pkgs.systemd}/bin/reboot"
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
    pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };
}
