{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;

  cfg = config.dotnix.nix;

  lix = pkgs.lixPackageSets.stable;
in

{
  options.dotnix.nix.caches = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          url = mkOption { type = types.str; };
          key = mkOption { type = types.str; };
        };
      }
    );
    description = ''
      Binary caches on top of cache.nixos.org. Definitions from several
      places (dotnix-private) are concatenated.
    '';
  };

  config = {
    dotnix.nix.caches = [
      {
        url = "https://nix-community.cachix.org";
        key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      }
      {
        url = "https://charon.cachix.org";
        key = "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8=";
      }
    ];

    nix = {
      package = lix.lix;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # root is already trusted
        trusted-users = [ config.dotnix.user ];
        extra-substituters = map (cache: cache.url) cfg.caches;
        extra-trusted-public-keys = map (cache: cache.key) cfg.caches;
      };
    };

    nixpkgs = {
      config.allowUnfree = true;

      overlays = [
        inputs.nixbuilds.overlays.default

        # nix tools built against lix instead of cppnix
        (_: prev: {
          inherit (prev.lixPackageSets.stable)
            colmena
            nix-eval-jobs
            nix-fast-build
            nixpkgs-review
            ;
        })
      ];
    };
  };
}
