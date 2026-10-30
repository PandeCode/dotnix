# building iphone apps with xtool and installing them over usb. usbmuxd
# talks to the phone, xtool and the libimobiledevice tools talk to usbmuxd
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotnix.profiles.ios;
in

{
  options.dotnix.profiles.ios.enable = lib.options.mkEnableOption "xtool and usbmuxd for iphone apps";

  config = lib.modules.mkIf cfg.enable {
    services.usbmuxd.enable = true;

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      # ideviceinfo, idevicesyslog and friends
      libimobiledevice
      xtool
      # keep-sorted end
    ];
  };
}
