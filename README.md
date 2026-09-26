# dotnix

My NixOS config. The private parts (secrets, network drives, private DNS)
live in a separate repo that builds on this one.

```bash
nix develop
just switch     # build this machine and switch
just build      # build and show what changes
just check      # evaluate every host, run the checks
just update     # update inputs
```

## Layout

```
flake.nix           inputs only
modules/
  flake/            outputs, lib (mkHost), checks
  generic/          every class: dotnix.* options, nix (lix, caches), home-manager
  nixos/ wsl/ iso/ darwin/
                    one per class; each imports generic/
  home/             home-manager modules
  wm/               window managers, drop-in modules
hosts/<name>/       one folder per machine
home/<user>/        one folder per user
old/                the previous config, until it is ported
```

## Hosts

A machine is `hosts/<name>/default.nix` plus one line in
`modules/flake/default.nix`:

```nix
nixosConfigurations = mkHosts {
  kazuha = { };
  <name> = { };                        # x86_64 nixos
  <name> = { arch = "aarch64"; };
  <name> = { class = "iso"; };
  <name> = { class = "wsl"; };         # needs the nixos-wsl input
};

darwinConfigurations = mkHosts {
  <name> = { arch = "aarch64"; class = "darwin"; };   # needs the darwin input
};
```

`mkHost` loads `hosts/<name>` and `modules/<class>`, and sets the host
name and platform. For a new machine, generate its hardware file on it:

```bash
nixos-generate-config --show-hardware-config > hosts/<name>/hardware.nix
```

## Drop-in modules

Modules under `modules/wm/` (more to come) only read their own
`dotnix.<name>` options, so they work in any config:

```nix
imports = [ inputs.dotnix.nixosModules.niri ];
dotnix.niri.enable = true;
```

`nix flake check` evaluates each one alone to keep it that way.
