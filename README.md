# Files for Backing Up and Reproducing My NixOS System on WSL
[![Build and Tag ISO](https://github.com/PandeCode/dotnix/actions/workflows/build_iso.yml/badge.svg)](https://github.com/PandeCode/dotnix/actions/workflows/build_iso.yml)
> Very much a WIP

Building the iso fails locally so git commits beging with "build-iso" trigger and action that build the iso.
The iso genetated is about 3.7GB and github releases have a max filesize of 2GB.
So I split the iso into compatibale sizes using a prefix of ISO*PART*.

Download the files(curl, wget, axel, Direct Download)

Use cat in a POSIX compliant shell with glob support(or a manual ref).

```bash
cat ISO_PART_* > nixiso.iso
# or
cat INSTALL_ISO_PART_* > nixiso.iso
```

> Because of the nature of the files, it will trigger security in flashers like Rufus. You can ignore this.

> **Note**: This setup is primarily for my personal use and _will_ break about 95% of the time with hardcoded paths and bugs that I will refuse to fix for a while. Feel free to take inspiration from it, though I’m not sure why you would want to.

## Why NixOS?

- NixOS is the new Arch btw.
- It presents a fresh challenge and learning opportunity.
- I love the reproducibility that NixOS offers, allowing easy system restoration and version tracking.

## Why Windows?

- Some programs required for schoolwork are Windows-only, and the school does not provide licenses for more than one installation (e.g., Logger Pro, Vernier, Wolfram Player).
- Other people may need to use my computer but can't work with a WindoManger.
- To avoid the distraction of ricing (ironically, I'm here creating a new dotfiles repo).
- Gaming is easier on Windows.
- Managing Wine can be cumbersome and has been a headache in the past.

## Why WSL?

- I am a former pure Linux desktop user.
- The tooling on Windows is absoulte trash, compared to linux, especially for development.
- WSL provides a more familiar Linux-like environment.

# System Names

- `shawn` is the default username on all systems
- `wslnix` is the windows config
- `nixiso` is the portable iso config

- `kazuha` is the laptop configuration _TODO_
- `jinwoo` is the PC configuration _TODO_
- `herta` is the Darwin configuration _TODO_
