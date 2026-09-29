# unlike the drop-in modules, profiles read dotnix.* and set other modules'
# options
{
  imports = [
    # keep-sorted start
    ./apps.nix
    ./base.nix
    ./boot.nix
    ./desktop.nix
    ./dev.nix
    ./gaming.nix
    ./laptop.nix
    ./security.nix
    ./theme.nix
    # keep-sorted end
  ];
}
