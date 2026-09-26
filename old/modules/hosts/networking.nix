{
  pkgs,
  sharedConfig,
  ...
}: {
  networking = {
    inherit (sharedConfig) hostName;

    # wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        # networkmanager-fortisslvpn
        # networkmanager-iodine
        # networkmanager-l2tp
        # networkmanager-openconnect
        networkmanager-openvpn
        # networkmanager-sstp
        # networkmanager-strongswan
        # networkmanager-vpnc
      ];
      # dns = "none";
      # wifi = {
      #   backend = "iwd";
      #   powersave = true;
      # };
    };
  };
}
