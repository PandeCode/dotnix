# push notifications to the phone, at ntfy.<domain>; other units report
# their failures here through dotnix.notify
{ config, lib, ... }:

let
  cfg = config.dotnix.services.ntfy;
  port = 2586;
in

{
  options.dotnix.services.ntfy.enable = lib.options.mkEnableOption "ntfy, at ntfy.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.${config.dotnix.home.domain}";
        listen-http = "127.0.0.1:${toString port}";
        behind-proxy = true;
      };
    };

    dotnix = {
      home.sites.ntfy = { inherit port; };
      backup.paths = [ "/var/lib/private/ntfy-sh" ];
      notify.url = lib.modules.mkDefault "http://127.0.0.1:${toString port}/${config.networking.hostName}";
    };
  };
}
