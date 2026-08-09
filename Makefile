all: update os home

update:
	nix flake update

os:
	@echo no
	false
	sudo echo OS
	nh os switch ~/dotnix-private -- --show-trace -vL --accept-flake-config --keep-going --extra-experimental-features nix-command --extra-experimental-features flakes

home:
	@echo no
	false
	nh home switch ~/dotnix-private/ -- --show-trace -vL --accept-flake-config --keep-going --extra-experimental-features nix-command --extra-experimental-features flakes
