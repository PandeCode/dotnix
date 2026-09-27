{
  imports = [ ./hardware.nix ];

  dotnix = {
    user = "@user@";

    profiles = {
      apps.enable = true;
      base.enable = true;
      desktop.enable = true;
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # the release this machine was installed with, not the current one
  system.stateVersion = "@stateVersion@";
}
