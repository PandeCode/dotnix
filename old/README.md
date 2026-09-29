#### my nix config

This setup is primarily for my personal use and _will_ break about 95% of the time with hardcoded paths and bugs that I will refuse to fix for a while.
Feel free to take inspiration from it, though I’m not sure why you would want to. its also easier for me if this is public

#### brainstorming

dotnix will be a specialArg but i will use it like

```nix
{pkgs, ... } @ args: let dotnix = if args ? "dotnix" then args.dotnix else { config = { something_i_need = false; val = "default"; } }; in {}
```

sharedConfig -> dotnix.config
dotutils -> dotnix.lib

dotutils will also be an extension of Pandecode/nixutils.lib

fancy idea

have a script that will look for functions from dotnix.lib and implement them at the top of a module so if for some reason someone else likes a module i write then they can use it

idk if i should minimize

#### iso is broke

```bash
git clone --recurse-submodules --depth 1 --shallow-submodules
```

[![Build and Tag ISO](https://github.com/PandeCode/dotnix/actions/workflows/build_iso.yml/badge.svg)](https://github.com/PandeCode/dotnix/actions/workflows/build_iso.yml)
[![Cachix](https://github.com/PandeCode/dotnix/actions/workflows/ci.yml/badge.svg)](https://github.com/PandeCode/dotnix/blob/cachix/.github/workflows/ci.yml)

> Very much a WIP

The iso genetated is about 3GB+ and github releases have a max filesize of 2GB.
So I split the iso into compatibale sizes using a prefix of ISO*PART*.

Download the files(curl, wget, axel, Direct Download)

Use cat in a shell with glob support(or a manual ref).

```bash
cat ISO_PART_* > nixiso.iso
# or
cat INSTALL_ISO_PART_* > nixiso.iso
```

> Because of the nature of the files, it will trigger security in flashers like Rufus. You can ignore this.
