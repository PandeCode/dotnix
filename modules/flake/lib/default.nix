{ lib, inputs }:

lib.fixedPoints.makeExtensible (_: {
  mkHost = import ./mkhost.nix { inherit lib inputs; };
})
