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
> This setup is primarily for my personal use and _will_ break about 95% of the time with hardcoded paths and bugs that I will refuse to fix for a while. Feel free to take inspiration from it, though I’m not sure why you would want to.
