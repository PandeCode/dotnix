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

  # nixpkgs passes -Dmimalloc to every lix, but only 2.96 has that option, so
  # stable (2.95) fails to configure and hydra has no build of it. 2.96 is
  # cached; this goes back to stable on its own once stable moves past 2.95
  lixFrom =
    sets:
    if lib.strings.versionOlder sets.stable.lix.version "2.96" then sets.lix_2_96 else sets.stable;

  lix = lixFrom pkgs.lixPackageSets;

  # my flakes that shells outside a flake can use as <name>, and the cli as
  # name#package, both at the revision this machine was built from
  mine = [
    "nixbuilds"
    "nixutils"
  ];
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

      registry = lib.attrsets.genAttrs mine (name: {
        flake = inputs.${name};
      });

      # setting it drops the default from nixpkgs.flake.setNixPath, so nixpkgs
      # and the channels are listed again. the /etc path stays the same across
      # rebuilds, so open shells see a switch without logging in again
      nixPath = [
        "nixpkgs=flake:nixpkgs"
      ]
      ++ map (name: "${name}=/etc/nix/inputs/${name}") mine
      ++ lib.lists.optional config.nix.channel.enable "/nix/var/nix/profiles/per-user/root/channels";
    };

    # a flake has no default.nix, so <name> gets one that loads its outputs.
    # `pkgs` is its legacyPackages for this machine
    environment.etc = lib.attrsets.listToAttrs (
      map (
        name:
        lib.attrsets.nameValuePair "nix/inputs/${name}/default.nix" {
          text = ''
            let
              flake = builtins.getFlake "path:${inputs.${name}}?narHash=${inputs.${name}.narHash}";
            in
            flake // { pkgs = flake.legacyPackages.''${builtins.currentSystem} or { }; }
          '';
        }
      ) mine
    );

    nixpkgs = {
      config.allowUnfree = true;

      overlays = [
        inputs.nixbuilds.overlays.default

        # nix tools built against lix instead of cppnix
        (_: prev: {
          inherit (lixFrom prev.lixPackageSets)
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
