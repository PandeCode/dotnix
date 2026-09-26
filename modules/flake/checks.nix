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

  inherit (lib.strings) hasInfix;

  niri = {
    nixos = nixos {
      imports = [ self.nixosModules.niri ];
      dotnix.niri.enable = true;
    };

    home = home {
      imports = [ self.homeModules.niri ];
      dotnix = {
        wm = {
          binds = [
            {
              mods = [ "Super" ];
              key = "Return";
              exec = "foot";
            }
          ];
          rules.float = [ "title:Picture-in-picture" ];
        };
        niri = {
          enable = true;
          includes = [ "~/live.kdl" ];
        };
      };
    };
  };

  river = {
    nixos = nixos {
      imports = [ self.nixosModules.river ];
      dotnix.river.enable = true;
    };

    home = home {
      imports = [ self.homeModules.river ];
      dotnix = {
        wm.binds = [
          {
            mods = [
              "Super"
              "Shift"
            ];
            key = "Return";
            exec = "foot";
          }
        ];
        river = {
          enable = true;
          # a friend without the nixbuilds overlay sets the package
          package = pkgs.writeShellScriptBin "rill" "";
          settings.center_focused_window._enum = "always";
        };
      };
    };
  };

  wm = home {
    imports = [ self.homeModules.wm ];
    dotnix.wm.terminal = "foot";
  };
in

{
  formatting = self.formatter.${system}.check self;

  drop-in-niri =
    assert lib.asserts.assertMsg niri.nixos.programs.niri.enable "niri: session not enabled";
    assert lib.asserts.assertMsg niri.nixos.dotnix.wayland.enable "niri: wayland basics not enabled";
    assert lib.asserts.assertMsg (hasInfix ''
      Super+Return {
      		spawn-sh "foot"'' niri.home.dotnix.niri.kdl) "niri: bind from dotnix.wm missing";
    assert lib.asserts.assertMsg
      (hasInfix ''match title="Picture-in-picture"'' niri.home.dotnix.niri.kdl)
      "niri: floating rule from dotnix.wm missing";
    assert lib.asserts.assertMsg (
      niri.home.xdg.configFile ? "niri/config.kdl"
    ) "niri: config.kdl not written";
    pkgs.runCommandLocal "drop-in-niri" { } "touch $out";

  drop-in-river =
    assert lib.asserts.assertMsg (lib.lists.elem "river" (
      map (p: p.pname or "") river.nixos.services.displayManager.sessionPackages
    )) "river: session not registered";
    assert lib.asserts.assertMsg river.nixos.dotnix.wayland.enable "river: wayland basics not enabled";
    assert lib.asserts.assertMsg
      (hasInfix ''.key = "Return", .modifiers = .{ .mod4 = true, .shift = true, }'' river.home.dotnix.river.zon)
      "river: bind from dotnix.wm missing";
    assert lib.asserts.assertMsg
      (hasInfix ".center_focused_window = .always" river.home.dotnix.river.zon)
      "river: enum not written";
    assert lib.asserts.assertMsg (river.home.xdg.configFile ? "river/init") "river: init not written";
    pkgs.runCommandLocal "drop-in-river" { } "touch $out";

  drop-in-wm =
    assert lib.asserts.assertMsg (wm.dotnix.wm.terminal == "foot") "wm: declaration not readable";
    pkgs.runCommandLocal "drop-in-wm" { } "touch $out";
}
