# what kazuha serves to other machines and the phone
{ config, pkgs, ... }:

let
  inherit (config.dotnix) user;
in

{
  dotnix = {
    profiles.ssh.enable = true;

    services.builder.use = "firefly";

    # the device ids are private
    services.syncthing = {
      enable = true;
      folders.main = "/home/${user}/vaults/main";
      lan = true;
    };
  };

  services.openssh.settings.X11Forwarding = true;

  programs = {
    gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

    weylus = {
      enable = true;
      users = [ user ];
    };
  };

  services = {
    xrdp = {
      enable = true;
      audio.enable = true;
    };

    gvfs.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };

    printing.enable = true;
  };

  # remote desktop only over tailscale: xrdp, weylus, wayvnc. kde connect
  # and avahi open their own
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    3389
    1701
    9001
    5900
  ];

  home-manager.users.${user}.programs.ledger.enable = true;
}
