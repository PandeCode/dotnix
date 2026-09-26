# hosts are checked by `nix flake check` itself (it evaluates every
# nixosConfiguration). these check the rest: formatting, and that each
# drop-in module works alone, with nothing else from this repo
{ pkgs, inputs }:

let
  inherit (inputs) self;
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) system;

  nixos =
    module:
    (import "${pkgs.path}/nixos/lib/eval-config.nix" {
      system = null;
      modules = [
        module
        {
          nixpkgs.hostPlatform = system;
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
          };
          system.stateVersion = "26.05";
        }
      ];
    }).config;

  home =
    module:
    (import "${inputs.home-manager}/modules" {
      inherit pkgs;
      configuration = {
        imports = [ module ];
        home = {
          username = "friend";
          homeDirectory = "/home/friend";
          stateVersion = "26.05";
        };
      };
    }).config;

  enabledFiles =
    config: lib.attrsets.attrNames (lib.attrsets.filterAttrs (_: f: f.enable) config.xdg.configFile);

  niri = {
    session =
      (nixos {
        imports = [ self.nixosModules.niri ];
        dotnix.niri.enable = true;
      }).programs.niri.enable;

    off = enabledFiles (home self.homeModules.niri);

    live = enabledFiles (home {
      imports = [ self.homeModules.niri ];
      dotnix.niri = {
        enable = true;
        liveConfigDir = "/home/friend/src/niri";
      };
    });
  };
in

{
  formatting = self.formatter.${system}.check self;

  drop-in-niri =
    assert lib.asserts.assertMsg niri.session "niri: session not enabled";
    assert lib.asserts.assertMsg (!lib.lists.elem "niri" niri.off) "niri: config linked while off";
    assert lib.asserts.assertMsg (lib.lists.elem "niri" niri.live) "niri: live config not linked";
    pkgs.runCommandLocal "drop-in-niri" { } "touch $out";
}
