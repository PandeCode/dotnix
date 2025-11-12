{pkgs ? import <nixpkgs> {}}: let
  buildInputs = with pkgs;
    [
      sdl3
      # Wayland dependencies
      wayland
      wayland-protocols
      wayland-scanner
      libxkbcommon
      libGL
      glew
      glfw
      cmake
      libdrm
      libgbm
      expat

      mesa
      # Audio
      alsa-lib
      # System
      udev
      # GObject/GTK dependencies
      glib
      gobject-introspection
      gtk3
      gtk4
      cairo
      pango
      gdk-pixbuf
      atk
      # VSCode dependencies
      nss
      nspr
      at-spi2-atk
      at-spi2-core
      dbus
      cups

      libsecret
      util-linux

      fontconfig
      freetype
      harfbuzz

      systemd
      libnotify

      _0xproto
    ]
    ++ (with xorg; [
      libxkbfile
      libXcomposite
      libXdamage
      libXfixes
      libXtst
      libxcb
      libX11
      libXcursor
      libXi
      libXinerama
      libXrandr
      libXext
    ]);
in
  (pkgs.buildFHSEnv {
    name = "fsh-env";
    targetPkgs = pkgs:
      buildInputs
      ++ (with pkgs; [
        gobject-introspection
        # Additional packages that might be needed
        pkg-config
        gcc
        glibc
      ]);
    multiPkgs = pkgs: (with pkgs; [
      udev
      alsa-lib
    ]);

    # Set up environment variables properly
    profile = ''
      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH
      export PKG_CONFIG_PATH=${pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" buildInputs}:$PKG_CONFIG_PATH
      export C_INCLUDE_PATH=${pkgs.lib.makeSearchPathOutput "dev" "include" buildInputs}:$C_INCLUDE_PATH
      export CPLUS_INCLUDE_PATH=${pkgs.lib.makeSearchPathOutput "dev" "include" buildInputs}:$CPLUS_INCLUDE_PATH
    '';

    runScript = "fish";
  }).env
