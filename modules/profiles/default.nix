# my bundles of settings, each off until a host enables it. unlike the
# drop-in modules these read dotnix.* and set other modules' options
{
  imports = [
    # keep-sorted start
    ./desktop.nix
    ./theme.nix
    # keep-sorted end
  ];
}
