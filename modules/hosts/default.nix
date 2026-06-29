{sharedConfig, ...}: {
  imports = [
    ./nix.nix
    ./networking.nix
    ./services.nix
    ./packages.nix
    ./security.nix
    ./shells.nix
  ];

  environment.sessionVariables = {
    NIX_BUILD_CORES = 6;
    EDITOR = sharedConfig.editor;
    TERMINAL = sharedConfig.terminal;
    BROWSER = sharedConfig.browser;
    DOTFILES = "/home/${sharedConfig.user}/dotnix";
  };

  # environment.etc.inputrc.text = ''
  #   ${builtins.readFile ../../config/inputrc}
  # '';

  services = {
    isLaptop = true;
  };

  # services.displayManager.ly = {
  #   enable = true;
  #   x11Support = true;
  #   settings = {};
  # };

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
