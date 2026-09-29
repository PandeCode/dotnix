# a module of the system, so one switch builds both
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
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs self; };
    users.${config.dotnix.user} = "${self}/home/${config.dotnix.user}";
  };
}
