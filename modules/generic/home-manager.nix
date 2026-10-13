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
    # apps rewrite files like mimeapps.list; an old backup must not stop the switch
    backupFileExtension = "hm-backup";
    overwriteBackup = true;
    extraSpecialArgs = { inherit inputs self; };
    users.${config.dotnix.user} = "${self}/home/${config.dotnix.user}";
  };
}
