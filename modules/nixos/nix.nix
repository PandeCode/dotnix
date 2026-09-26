{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };

    settings = {
      # free up to 1GiB whenever there is less than 100MiB left
      min-free = 100 * 1024 * 1024;
      max-free = 1024 * 1024 * 1024;
    };
  };
}
