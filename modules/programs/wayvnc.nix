{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wayvnc;
in {
  options.wayvnc.enable = lib.mkEnableOption "enable wayvnc";

  config = lib.mkIf cfg.enable {
    # xdg.configFile = {
    # "wayvnc/config".text = '''';
    # };
    # (
    #
    # openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -sha384 \
    # -days 3650 -nodes -keyout tls_key.pem -out tls_cert.pem \
    # -subj /CN=localhost \
    # -addext subjectAltName=DNS:localhost,DNS:localhost,IP:127.0.0.1
    # )
    home.packages = with pkgs; [
      wayvnc
    ];
  };
}
