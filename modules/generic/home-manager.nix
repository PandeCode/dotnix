# home-manager as a module of the system, so one switch builds both. the
# class module imports home-manager's nixos or darwin module
{
  config,
  inputs,
  self,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs self; };
    users.${config.dotnix.user} = "${self}/home/${config.dotnix.user}";
  };
}
