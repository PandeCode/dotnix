# search.<domain>: a search of every dotnix.* option, built from this
# machine's own options, and every nixbuilds package
{
  config,
  inputs,
  lib,
  options,
  pkgs,
  self,
  ...
}:

{
  options.dotnix.services.search.enable =
    lib.options.mkEnableOption "a search of dotnix options and nixbuilds packages, at search.<domain>";

  config = lib.modules.mkIf config.dotnix.services.search.enable {
    dotnix.home.sites.search.root = pkgs.callPackage "${self}/docs/search" {
      inherit inputs options self;
    };
  };
}
