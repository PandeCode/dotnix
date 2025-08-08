{sharedConfig, ...}: {
  imports = let
    ifl = i: l: (
      if i
      then [l]
      else []
    );
  in
    [
      ../../modules/programs/default.nix
      ../../modules/homes/links.nix

      ../../modules/homes/stylix.nix
      ../../modules/wm/default.home.nix
    ]
    ++ (ifl sharedConfig.virt_manager.enable ../../modules/homes/virt_manager.nix)
    ++ (ifl sharedConfig.gaming.enable ../../modules/toolsets/gaming/home.nix);

  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;
  services.kdeconnect.enable = true;
}
