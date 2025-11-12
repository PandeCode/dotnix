all: update os home

update:
	nix flake update

os:
	sudo echo OS
	nh os switch ~/dotnix -- --show-trace -vL --accept-flake-config --keep-going --extra-experimental-features nix-command --extra-experimental-features flakes

home:
	nh home switch ~/dotnix -- --show-trace -vL --accept-flake-config --keep-going --extra-experimental-features nix-command --extra-experimental-features flakes
