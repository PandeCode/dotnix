{sharedConfig, ...}: {
  # services.globalprotect.enable = true; # TODO security
  services.xrdp = {
    enable = true;
    audio.enable = true;
    openFirewall = true;
  };
  networking = {
    inherit (sharedConfig) hostName;

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
      allowedTCPPorts = [7000 7100 5900 5353];
      allowedUDPPorts = [6000 6001 7011 5900 5353];
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
