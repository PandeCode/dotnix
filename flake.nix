{
  description = "my nix config";

  # lets a fresh machine download instead of build before the caches in
  # modules/generic/nix.nix are set up
  nixConfig = {
    extra-substituters = [
      "https://charon.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs: import ./modules/flake inputs;

  inputs = {
    ### mine
    # the shared nixpkgs pin
    nixpkgs.follows = "nixbuilds/nixpkgs";

    # my packages, as an overlay
    nixbuilds = {
      type = "github";
      owner = "PandeCode";
      repo = "nixbuilds";
    };

    # my lib and the shared formatter config
    nixutils = {
      type = "github";
      owner = "PandeCode";
      repo = "nixutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim
    hermes = {
      type = "github";
      owner = "PandeCode";
      repo = "hermes";

      inputs = {
        nixbuilds.follows = "nixbuilds";
        nixutils.follows = "nixutils";
      };
    };

    # emacs
    libys = {
      type = "github";
      owner = "PandeCode";
      repo = "libys";

      inputs = {
        nixbuilds.follows = "nixbuilds";
        nixutils.follows = "nixutils";
      };
    };

    ### system
    # manage userspace with nix
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # per-model hardware settings
    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # colors, fonts and wallpaper for everything
    stylix = {
      type = "github";
      owner = "nix-community";
      repo = "stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # a patched spotify client
    spicetify-nix = {
      type = "github";
      owner = "Gerg-L";
      repo = "spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # prebuilt nix-index database, for comma and command-not-found
    nix-index-database = {
      type = "github";
      owner = "nix-community";
      repo = "nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
