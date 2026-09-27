# dotnix

My NixOS config. The private parts (secrets, network drives, private DNS)
live in a separate repo that builds on this one.

```bash
nix develop
just switch     # build this machine and switch
just build      # build and show what changes
just check      # evaluate every host, run the checks
just update     # update inputs
just iso        # build the live system and installer
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
  profiles/         my bundles of settings, turned on per host
  hardware/         drop-in hardware modules
  wm/               window managers, drop-in modules
packages/           scripts (bin/), c-tools (src/), dotnix-install
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

## Live system

`just iso` builds `result/iso/*.iso`: my desktop, shell, editors and theme
on any machine, logged in as me. Write it to a stick with
`dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress`.

On it, mount the target at `/mnt` and run `dotnix-install`. It installs
one of the machines in `hosts/`, sets up a new one (a host folder, its
hardware file and a line in the host list), or plain NixOS. The config
ends up in `~/dotnix` on the new machine; commit the new host from there.

## Drop-in modules

Modules under `modules/wm/` (more to come) only read their own
`dotnix.<name>` options, so they work in any config:

```nix
imports = [ inputs.dotnix.nixosModules.niri ];
dotnix.niri.enable = true;
```

`nix flake check` evaluates each one alone to keep it that way.
