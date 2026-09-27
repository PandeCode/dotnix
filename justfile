flake := justfile_directory()

[private]
default:
    @just --list --unsorted

# build this machine and switch to it
switch *args:
    nh os switch {{ flake }} {{ args }}

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
    nix flake update {{ inputs }}
