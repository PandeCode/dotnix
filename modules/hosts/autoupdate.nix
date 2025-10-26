{
  input,
  lib,
  config,
  ...
}: {
  options = {
    autoupdate.enable = lib.mkEnableOption "enables autoupdates";
  };

  config = lib.mkIf config.autoupdate.enable {
    system.autoUpgrade = {
      enable = true;
      flake = input.self.outPath;
      flags = ["--update-input" "nixpkgs" "-L"];
      dates = "09:00";
      randomizedDelaySec = "45min";
    };
  };
}
