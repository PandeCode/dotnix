{ lib, inputs }:

let
  inherit (inputs) nixpkgs self;
in

/**
  Build a machine from `hosts/<name>` and `modules/<class>`.

  # Example

  ```nix
  mkHost "kazuha" { }
  mkHost "herta" { arch = "aarch64"; class = "darwin"; }
  # from dotnix-private, adding modules to a public host
  inputs.dotnix.lib.mkHost "kazuha" { modules = [ ./kazuha.nix ]; }
  ```
*/
name:
{
  arch ? "x86_64",
  # nixos, wsl, iso or darwin
  class ? "nixos",
  modules ? [ ],
}:

let
  os = if class == "darwin" then "darwin" else "linux";

  evalHost =
    if class == "darwin" then
      (inputs.darwin or (throw "darwin hosts need the nix-darwin input, named darwin")).lib.darwinSystem
    else
      nixpkgs.lib.nixosSystem;
in

evalHost {
  # only what `imports` needs; everything else goes through _module.args
  specialArgs = { inherit inputs self; };

  modules = [
    "${self}/hosts/${name}"
    "${self}/modules/${class}"

    {
      key = "dotnix#host";
      _file = "${__curPos.file}";

      networking.hostName = name;
      nixpkgs.hostPlatform = "${arch}-${os}";
    }
  ]
  ++ lib.lists.optional (class == "darwin") {
    key = "dotnix#nixpkgs-darwin";
    _file = "${__curPos.file}";

    # nix-darwin refuses to build without it
    nixpkgs.source = nixpkgs;
  }
  ++ modules;
}
