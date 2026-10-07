flake := justfile_directory()

[private]
default:
    @just --list --unsorted

# build this machine and switch to it
switch *args:
    nh os switch {{ flake }} {{ args }}

# the same, with the builds on dotnix.services.builder.use
switch-remote *args:
    nh os switch {{ flake }} {{ args }} -- --builders @/etc/nix/machines

# build this machine and switch to it on next boot
boot *args:
    nh os boot {{ flake }} {{ args }}

# build this machine and show what would change
build *args:
    nh os build {{ flake }} {{ args }}

# build the live system, into result/iso/
iso *args:
    nix build {{ flake }}#nixosConfigurations.iso.config.system.build.isoImage {{ args }}

# evaluate every host and run the checks
check *args:
    nix flake check {{ args }}

fmt:
    nix fmt

# update all inputs, or only the ones named
update *inputs:
    nix --accept-flake-config flake update {{ inputs }}

# the search of every dotnix option and nixbuilds package, at
# http://localhost:8080
search:
    nix build {{ flake }}#search
    nix run nixpkgs#http-server -- result
