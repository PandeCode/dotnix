{nixConfig, ...}: {
  nix = {
    settings = nixConfig;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = ["03:45"];
    };

    # free up to 1GiB whenever there is less than 100MiB left
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}'';
  };
}
