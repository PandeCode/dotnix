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
      min-free = 100 * 1024 * 1024;
      max-free = 1024 * 1024 * 1024;
    };
  };
}
