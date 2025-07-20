{
  pkgs,
  lib,
  config,
  ...
}: let
  libs = with pkgs;
    [
      # Core C/C++ runtime
      stdenv.cc.cc.lib
      glibc
      zlib
      bzip2
      xz
      zstd
      llvmPackages.libcxx

      # System
      dbus
      systemd
      libudev0-shim

      # Graphics
      libGL
      libglvnd
      libdrm
      mesa

      # X11
      # Wayland
      wayland
      libxkbcommon

      # Audio
      alsa-lib
      pulseaudio
      libpulseaudio

      # GUI / GTK
      gtk3
      gtk4
      gdk-pixbuf
      cairo
      pango
      freetype
      fontconfig

      # Input
      libwacom
      libinput

      # FS / Utils
      fuse3
      e2fsprogs
      util-linux
      curl
      expat
      gamemode

      # Media
      ffmpeg
      libva
      libvdpau
    ]
    ++ (
      with pkgs.xorg; [
        libX11
        libXext
        libXrender
        libXfixes
        libXi
        libXrandr
        libXcursor
        libXinerama
        libXcomposite
        libXdamage
        libXScrnSaver
        libxcb
        xcbutil
        xcbutilimage
        xcbutilkeysyms
        xcbutilcursor
        xcbutilwm
      ]
    );
in {
  programs.nix-ld = {
    enable = true;
    libraries = libs;
  };

  # Optional: remove this unless you know you need it manually
  # environment.sessionVariables = {
  #   LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath libs}";
  #   INCLUDE_PATH = "${pkgs.lib.makeIncludePath libs}";
  # };
}
