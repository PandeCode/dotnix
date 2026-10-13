flake := justfile_directory()

[private]
default:
    @just --list --unsorted

# with the private flake here, it is the one that builds this machine
[private]
guard:
    @if [ -d ~/dotnix-private ] && [ "{{ flake }}" != "$HOME/dotnix-private" ]; then echo "this machine is built from ~/dotnix-private; run it there, or just switch-local there to try this clone" >&2; exit 1; fi

# build this machine and switch to it
switch *args: guard
    nh os switch {{ flake }} {{ args }}

# the same, with the builds on dotnix.services.builder.use
switch-remote *args: guard
    nh os switch {{ flake }} {{ args }} -- --builders @/etc/nix/machines

# build this machine and switch to it on next boot
boot *args: guard
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
