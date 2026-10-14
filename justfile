flake := justfile_directory()

nix_args := "--keep-going --accept-flake-config"

[private]
default:
    @just --list --unsorted

# with the private flake here, it is the one that builds this machine
[private]
guard:
    @if [ -d ~/dotnix-private ] && [ "{{ flake }}" != "$HOME/dotnix-private" ]; then echo "this machine is built from ~/dotnix-private; run it there, or just switch-local there to try this clone" >&2; exit 1; fi

# build this machine and switch to it
switch *args: guard
    nh os switch {{ flake }} {{ args }} -- {{ nix_args }}

# the same, with the builds on dotnix.services.builder.use
switch-remote *args: guard
    nh os switch {{ flake }} {{ args }} -- {{ nix_args }} --builders @/etc/nix/machines

# build this machine and switch to it on next boot
boot *args: guard
    nh os boot {{ flake }} {{ args }} -- {{ nix_args }}

# build this machine and show what would change
build *args:
    nh os build {{ flake }} {{ args }} -- {{ nix_args }}

# build the live system, into result/iso/
iso *args:
    nix {{ nix_args }} build {{ flake }}#nixosConfigurations.iso.config.system.build.isoImage {{ args }}

# evaluate every host and run the checks
check *args:
    nix flake check {{ nix_args }} {{ args }}

fmt:
    nix {{ nix_args }} fmt

# update all inputs, or only the ones named
update *inputs:
    nix flake update {{ inputs }} {{ nix_args }}

# the search of every dotnix option, at http://localhost:8080; the published
# one is at pandecode.github.io/dotnix
search:
    nix {{ nix_args }} build {{ flake }}#search
    nix run nixpkgs#http-server -- result
