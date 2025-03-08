{sharedConfig, ...}: {
  # programs.kdeconnect.enable = true;
  # programs.localsend.enable = true;
  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #
  #   settings = {
  #     devices = {
  #       "device" = {id = "DEVICE-ID-GOES-HERE";};
  #       "chaos" = {id = "DEVICE-ID-GOES-HERE";};
  #     };
  #     folders = {
  #       "School" = {
  #         path = "/home/${sharedConfig.username}/Vaults/School";
  #         devices = ["device" "chaos"];
  #         ignorePerms = false;
  #       };
  #     };
  #   };
  # };
  # systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
