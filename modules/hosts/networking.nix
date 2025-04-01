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

  networking = {
    firewall = rec {
      enable = true;
      allowedTCPPorts = [7000 7100 5900];
      allowedUDPPorts = [6000 6001 7011 5900];
      allowedTCPPortRanges = [
        {
          from = 30000;
          to = 60000;
        }
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
    # networkmanager = {
    #   enable = true;
    #   dns = "none";
    #   # wifi.powersave = true;
    # };

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
