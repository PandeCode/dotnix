{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.dotnix.profiles.dev;
in {
  options.dotnix.profiles.dev.enable = lib.options.mkEnableOption "my development setup";

  config = lib.modules.mkIf cfg.enable {
    documentation.dev.enable = true;

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.users.${config.dotnix.user}.extraGroups = ["docker"];

    # FPGA boards, TI launchpads, arduinos
    services.udev.extraRules = builtins.readFile ../../config/udev/60-boards.rules;

    # binaries built for other distros, and pip or npm packages that ship them
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # keep-sorted start
        SDL
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL_image
        SDL_mixer
        SDL_ttf
        acl
        alsa-lib
        atk
        attr
        bzip2
        cairo
        coreutils
        cups
        curl
        dbus
        dbus-glib
        e2fsprogs
        expat
        ffmpeg
        flac
        fontconfig
        freeglut
        freetype
        fuse
        fuse3
        gamemode
        gdk-pixbuf
        glew_1_10
        glib
        glibc
        gsettings-desktop-schemas
        gtk2
        gtk3
        gtk4
        icu
        libGL
        libcaca
        libcanberra
        libcap
        libdrm
        libelf
        libgbm
        libgcrypt
        libglvnd
        libice
        libidn
        libinput
        libjpeg
        libmikmod
        libnotify
        libogg
        libpng
        libpng12
        libpulseaudio
        librsvg
        libsamplerate
        libsm
        libsodium
        libssh
        libtheora
        libtiff
        libudev0-shim
        libusb1
        libva
        libvdpau
        libvorbis
        libvpx
        libwacom
        libx11
        libxcb
        libxcomposite
        libxcrypt
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxft
        libxi
        libxinerama
        libxkbcommon
        libxml2
        libxmu
        libxrandr
        libxrender
        libxscrnsaver
        libxshmfence
        libxt
        libxtst
        libxxf86vm
        llvmPackages.libcxx
        mesa
        networkmanager
        nspr
        nss
        openssl
        openxr-loader
        pango
        pciutils
        pipewire
        pixman
        pulseaudio
        sdl3
        speex
        stdenv.cc.cc
        stdenv.cc.cc.lib
        systemd
        tbb
        util-linux
        wayland
        xcbutil
        xcbutilcursor
        xcbutilimage
        xcbutilkeysyms
        xcbutilwm
        xz
        zenity
        zlib
        zstd
        # keep-sorted end
        # vulkan-loader breaks things here
      ];
    };

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      (python3.withPackages (
        ps:
          with ps; [
            # keep-sorted start
            ds4drv
            matplotlib
            numpy
            pandas
            pygments
            requests
            scipy
            sympy
            uncertainties
            youtube-transcript-api
            # keep-sorted end
          ]
      ))
      android-tools
      appimage-run
      codeberg-cli
      fennel-ls
      gcc
      gnumake
      luajit
      luajitPackages.fennel
      nodejs
      pre-commit
      subversion
      # keep-sorted end
    ];

    # kept in the store for nix-shell, not on PATH
    system.extraDependencies = with pkgs; [
      # keep-sorted start
      bear
      cargo
      cgdb
      clang
      clang-tools
      gdb
      llvm_22
      pkg-config
      rr
      tinymist
      typst
      zig
      zls
      # keep-sorted end
    ];
  };
}
