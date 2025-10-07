inputs:
with inputs; {
  nixpkgs.overlays = [
    (_final: prev: {
      zjstatus = zjstatus.packages.${prev.system}.default;
      ghostty = ghostty.packages.${prev.system}.default;
    })
  ];
}
