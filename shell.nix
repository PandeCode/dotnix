{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nh
    statix
    nixd
    nix-init
    nix-index
    nix-fast-build

    ghc
  ];

  shellHook = ''
    # export PATH=$PATH:
  '';
}
