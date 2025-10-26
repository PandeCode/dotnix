{sharedConfig, ...}: {
  imports = [
    ./nix.nix
    ./networking.nix
    ./services.nix
    ./packages.nix
    ./security.nix
  ];

  environment.sessionVariables = {
    NIX_BUILD_CORES = 6;
    EDITOR = sharedConfig.editor;
    TERMINAL = sharedConfig.terminal;
    BROWSER = sharedConfig.browser;
    DOTFILES = "/home/${sharedConfig.user}/dotnix";
  };

  services = {
    isLaptop = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
    # config.allowUnfreePredicate = pkg:
    #   builtins.elem (lib.getName pkg) [
    #     "google-chrome"
    #     "spotify"
    #     "obsidian"
    #   ];
  };
}
