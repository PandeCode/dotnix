update:
	sudo echo Update
	# nix flake update
	nh os switch ~/dotnix/ -- --show-trace -vL --accept-flake-config && nh home switch ~/dotnix/ -- --show-trace -vL --accept-flake-config


home:
	nh home switch ~/dotnix -- --show-trace -vL --accept-flake-config

os:
	sudo echo OS
	nh os switch ~/dotnix -- --show-trace -vL --accept-flake-config
