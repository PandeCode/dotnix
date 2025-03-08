nixpkgs: {
  flattenListAttrsToAttr = nixpkgs.lib.foldl' (a: b: a // b) {};
}
