# onFailure = [ "notify-failure@%n.service" ] on any unit sends its last log
# lines to dotnix.notify.url
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.notify) url;
in

{
  options.dotnix.notify.url = lib.options.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "http://127.0.0.1:2586/firefly";
    description = "An ntfy topic that failed units post to.";
  };

  config = lib.modules.mkIf (url != null) {
    systemd.services."notify-failure@" = {
      description = "Report the failure of %i";
      scriptArgs = "%i";
      path = [
        pkgs.curl
        config.systemd.package
      ];
      script = ''
        journalctl --unit "$1" --lines 20 --no-pager --output cat |
          curl --fail --silent --show-error \
            --header "Title: $1 failed" --header "Tags: warning" \
            --data-binary @- ${lib.strings.escapeShellArg url}
      '';
      serviceConfig.Type = "oneshot";
    };
  };
}
