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
      ../../modules/homes/stylix.nix
      ../../modules/wm/default.home.nix
    ]
    ++ (ifl sharedConfig.virt_manager.enable ../../modules/homes/virt_manager.nix)
    ++ (ifl sharedConfig.gaming.enable ../../modules/gaming/home.nix);

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home .stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;
  services.kdeconnect.enable = true;
}
