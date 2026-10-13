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
      # built as you, since nix won't open a git repo someone else owns
      script = ''
        system=$(runuser -u ${user} -- env HOME=${home} nix build --no-link --print-out-paths \
          --override-input dotnix ${cfg.dotnix} --no-write-lock-file \
          "git+file://${cfg.flake}#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel")
        if [ "$system" != "$(readlink -f /run/current-system)" ]; then
          nix-env --profile /nix/var/nix/profiles/system --set "$system"
          "$system/bin/switch-to-configuration" switch
        fi
      '';
      serviceConfig.Type = "oneshot";
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
