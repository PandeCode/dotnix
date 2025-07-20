{sharedConfig, ...}: {
  services.globalprotect.enable = true;
  networking = {
    hostName = sharedConfig.hostName;

    # wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      # dns = "none";
      # wifi = {
      #   backend = "iwd";
      #   powersave = true;
      # };
    };

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
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
