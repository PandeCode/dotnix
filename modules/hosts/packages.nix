{
  pkgs,
  # inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    coolercontrol = {
      enable = true;
      nvidiaSupport = true;
    };

    light.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3 fuse3];
    };
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; let
    luaPkgs = l: e:
      l.withPackages (p:
        with p;
          [
            luarocks-nix
          ]
          ++ e);
    advcpmv = (coreutils.override {singleBinary = false;}).overrideAttrs (
      old: let
        advcpmv-data = {
          pname = "advcpmv";
          patch-version = "0.9";
          coreutils-version = "9.3";
          version = "${advcpmv-data.patch-version}-${advcpmv-data.coreutils-version}";
          src = pkgs.fetchFromGitHub {
            owner = "jarun";
            repo = "advcpmv";
            rev = "a1f8b505e691737db2f7f2b96275802c45f65c59";
            hash = "sha256-IHfMu6PyGRPc87J/hbxMUdosmLq13K0oWa5fPLWKOvo=";
          };
          patch-file = advcpmv-data.src + "/advcpmv-${advcpmv-data.version}.patch";
        };
      in
        assert (advcpmv-data.coreutils-version == old.version); {
          inherit (advcpmv-data) pname version;

          patches =
            (old.patches or [])
            ++ [
              advcpmv-data.patch-file
            ];

          configureFlags =
            (old.configureFlags or [])
            ++ [
              "--program-prefix=adv"
            ];

          postInstall =
            (old.postInstall or [])
            + ''
              pushd $out/bin
              ln -s advcp cpg
              ln -s advmv mvg
              popd
            '';
          meta =
            old.meta
            // {
              description = "Coreutils patched to add progress bars";
            };
        }
    );
  in [
    # inputs.nix-software-center.packages.${system}.nix-software-center
    # inputs.nixos-conf-editor.packages.${system}.nixos-conf-editor

    # (luaPkgs luajit (with luaPackages; [luautf8]))
    # (luaPkgs lua5_2 (with luaPackages; [luautf8 luaffi luaposix]))
    # (luaPkgs lua5_4 [])

    alsa-utils
    stacer

    foot
    chafa

    pass
    qtpass
    gnupg
    pinentry

    nix-prefetch-github
    nix-init
    nurl

    nh
    nix-output-monitor
    deadnix
    statix
    nix-tree

    home-manager

    # nvtop

    # Build tools
    gnumake

    # Utilities
    busybox
    inetutils
    wget
    bat
    bat-extras.batpipe
    bat-extras.batman
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batwatch

    tealdeer
    wikiman

    expect # unbuffer command
    tree-sitter
    jq
    pipr
    htmlq
    p7zip
    gdb
    appimage-run

    # Shells and terminal tools
    fish
    zellij
    zoxide
    carapace
    starship
    atuin
    xclip
    fzf
    glow
    gum
    television
    fuzzel

    slurp
    grim

    # Version control
    git
    subversion

    pywal
    hellwal

    (aspellWithDicts
      (dicts: with dicts; [de en en-computers en-science es fr la]))

    # Python packages
    (python3.withPackages (python-pkgs:
      with python-pkgs; [
        fire
        pygments
        requests
        # Physics Stuff
        pandas
        numpy
        scipy
        matplotlib
        uncertainties
        sympy
        ds4drv

        youtube-transcript-api
        # pwntools
      ]))

    nodejs

    pulseaudio
    pwvucontrol

    ffmpeg
    mpv
    nsxiv
    pqiv

    systemctl-tui
    sysz

        caligula
        astroterm
        pastel
    # advcpmv
  ];
}
