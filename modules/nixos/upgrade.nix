# dotnix.upgrade: every night this machine builds its private flake with
# the newest dotnix and switches to it, so merged update prs land on their
# own. the clone and its lock file are left as they are
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix) user;
  inherit (config.users.users.${user}) home;

  cfg = config.dotnix.upgrade;
in

{
  options.dotnix.upgrade = {
    enable = lib.options.mkEnableOption "switching to the newest dotnix every night";

    flake = lib.options.mkOption {
      type = lib.types.str;
      default = "${home}/dotnix-private";
      defaultText = lib.literalExpression ''"<home of dotnix.user>/dotnix-private"'';
      description = "The clone of the private flake this machine is built from.";
    };

    dotnix = lib.options.mkOption {
      type = lib.types.str;
      default = "github:PandeCode/dotnix";
      description = "Where the newest dotnix comes from.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    systemd.services.dotnix-upgrade = {
      description = "Switch to the newest dotnix";
      onFailure = lib.lists.optional (config.dotnix.notify.url != null) "notify-failure@%n.service";
      path = [
        config.nix.package
        pkgs.git
        pkgs.util-linux
      ];
      # built as you, since nix won't open a git repo someone else owns.
      # only committed work is built, and dotnix brings its own lock, since
      # an override alone keeps the private lock's old pins under it
      script = ''
        as() { runuser -u ${user} -- env HOME=${home} "$@"; }
        flake="git+file://${cfg.flake}?ref=HEAD"
        lock=$(as mktemp -d)/flake.lock
        trap 'rm -rf "$(dirname "$lock")"' EXIT

        as nix flake update dotnix --flake "$flake" \
          --override-input dotnix ${cfg.dotnix} --output-lock-file "$lock"
        system=$(as nix build --no-link --print-out-paths \
          --reference-lock-file "$lock" --no-write-lock-file \
          "$flake#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel")

        # a switch that failed halfway is tried again the next night
        if [ "$system" != "$(cat "$STATE_DIRECTORY/system" 2>/dev/null)" ]; then
          nix-env --profile /nix/var/nix/profiles/system --set "$system"
          "$system/bin/switch-to-configuration" switch
          echo "$system" >"$STATE_DIRECTORY/system"
        fi
      '';
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "dotnix-upgrade";
        TimeoutStartSec = "3h";
      };
      # the switch it runs must not stop it halfway
      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;
    };

    # after the backup and the store cleanup; a missed night runs at boot
    systemd.timers.dotnix-upgrade = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "04:30";
        Persistent = true;
      };
    };
  };
}
