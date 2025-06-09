update:
	sudo echo Update
	nix flake update
	nh os switch ~/dotnix/ -- --show-trace -vL && nh home switch ~/dotnix/ -- --show-trace -vL


home:
	nh home switch ~/dotnix -- --show-trace -vL

os:
	sudo echo OS
	nh os switch ~/dotnix -- --show-trace -vL
