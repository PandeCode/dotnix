{pkgs ? import <nixpkgs> {}}: let
  pypi2nix = import (pkgs.fetchgit {
    url = "https://github.com/nix-community/pypi2nix";
    rev = "v2.0.1";
    sha256 = "0mxh3x8bck3axdfi9vh9mz1m3zvmzqkcgy6gxp8f9hhs6qg5146y";
  }) {};
in
  pkgs.mkShell {
    buildInputs = [
      pkgs.python3
      pkgs.git
      pypi2nix
    ];
  }
