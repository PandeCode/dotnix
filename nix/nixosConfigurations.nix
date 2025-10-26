self:
with self;
with inputs; let
  mkSystem = system: sys_name: extra_modules: args:
    nixpkgs.lib.nixosSystem {
      specialArgs =
        {
          inherit inputs outputs system sys_name dotutils nixConfig;
          pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
        }
        // args;
      modules =
        [
          {nix.settings = nixConfig;}
          overlays
          inputs.stylix.nixosModules.stylix
          ../hosts/${sys_name}/configuration.nix
        ]
        ++ extra_modules;
    };
  mkSystemLinux64 = mkSystem systems.x86_64-linux;
in {
  nixiso = mkSystemLinux64 "nixiso" [
    home-manager.nixosModules.home-manager
    inputs.spicetify-nix.nixosModules.default
  ] {sharedConfig = sharedConfig_kazuha;};
  # wslnix = mkSystemLinux64 "wslnix" [inputs.nixos-wsl.nixosModules.default];

  kazuha =
    mkSystemLinux64 "kazuha" [
    ] {sharedConfig = sharedConfig_kazuha;};
  # jinwoo = mkSystemLinux64 "jinwoo " [];
}
