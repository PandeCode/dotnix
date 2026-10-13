# a unit in dotnix.notify.units sends its last log lines to dotnix.notify.url
# when it fails. with dotnix.notify.disks, so does smartd when a drive starts
# to fail
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.notify) url disks units;

  # ntfy may be restarting in the same switch
  retry = "--retry 5 --retry-all-errors --retry-delay 15";

  # smartd hands over what it found in SMARTD_* variables
  smartdNotify = pkgs.writeShellScript "smartd-ntfy" ''
    ${lib.meta.getExe pkgs.curl} --fail --silent --show-error ${retry} \
      --header "Title: $SMARTD_DEVICE: $SMARTD_FAILTYPE" \
      --header "Tags: warning" --header "Priority: high" \
      --data-binary "$SMARTD_MESSAGE" ${lib.strings.escapeShellArg url}
  '';
in

{
  options.dotnix.notify = {
    url = lib.options.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://127.0.0.1:2586/firefly";
      description = "An ntfy topic that failed units post to.";
    };

    units = lib.options.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "restic-backups-main" ];
      description = "Services whose failures are posted to dotnix.notify.url.";
    };

    disks = lib.options.mkEnableOption "smartd checking every drive's health, with a short self-test daily and a long one weekly, and posting problems to dotnix.notify.url";
  };

  config = lib.modules.mkIf (url != null) {
    services.smartd = lib.modules.mkIf disks {
      enable = true;
      # its built-in alerts only reach someone at the screen
      notifications = {
        wall.enable = false;
        x11.enable = false;
      };
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04) -m <nomailer> -M exec ${smartdNotify}";
    };

    systemd.services =
      lib.attrsets.genAttrs units (_: {
        onFailure = [ "notify-failure@%n.service" ];
      })
      // {
        "notify-failure@" = {
          description = "Report the failure of %i";
          after = [ "ntfy-sh.service" ];
          scriptArgs = "%i";
          path = [
            pkgs.curl
            config.systemd.package
          ];
          script = ''
            journalctl --unit "$1" --lines 20 --no-pager --output cat |
              curl --fail --silent --show-error ${retry} \
                --header "Title: $1 failed" --header "Tags: warning" \
                --data-binary @- ${lib.strings.escapeShellArg url}
          '';
          serviceConfig.Type = "oneshot";
        };
      };
  };
}
