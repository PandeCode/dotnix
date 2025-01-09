{
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/hosts/default.nix
    ../../modules/desktop_env/hyprland.nix
  ];

  system.stateVersion = "24.05";

  networking.hostName = "nixiso";
  boot.kernelPackages = pkgs.linuxPackages_zen;

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      disko
      parted

      subversion
      git

      home-manager

      gnumake
      gcc

      miniserve

      ouch # unzip
      pipr

      # Utilities
      busybox

      inetutils
      sd

      bandwhich
      dust
      dua
      grex
      fclones
      htmlq

      wget

      bat
      expect # unbuffer command
      jq
      p7zip

      appimage-run

      # Shells and terminal tools
      fish
      nushell
      zellij
      zoxide
      carapace
      starship
      atuin
      xclip
      btop
      fzf

      # Node.js
      nodejs

      # Multimedia
      pulseaudio
      ffmpeg
      # install mpv to ensure display manager gets installed as a dependency
      mpv
      sxiv # Simple X Image Viewer https://github.com/muennich/sxiv

      # Python packages
      (pkgs.python3.withPackages (python-pkgs:
        with python-pkgs; [
          fire
          pygments
          pywal
          requests

          # Physics Stuff
          pandas
          numpy
          scipy
          matplotlib
          uncertainties
          sympy
          pwntools
        ]))
    ];
  };
}
