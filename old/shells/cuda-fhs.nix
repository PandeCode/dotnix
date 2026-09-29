# https://wiki.nixos.org/wiki/CUDA
{
  pkgs ?
    import <nixpkgs> {
      config.allowUnfree = true;
    },
}: let
  # Change according to the driver used: stable, beta
  nvidiaPackage = pkgs.linuxPackages.nvidiaPackages.stable;
in
  (pkgs.buildFHSEnv {
    name = "cuda-env";
    targetPkgs = pkgs:
      with pkgs; [
        git
        gitRepo
        gnupg
        autoconf
        curl
        procps
        gnumake
        util-linux
        m4
        gperf
        unzip
        cudatoolkit
        nvidiaPackage
        libGLU
        libGL
        xorg.libXi
        xorg.libXmu
        freeglut
        xorg.libXext
        xorg.libX11
        xorg.libXv
        xorg.libXrandr
        zlib
        ncurses5
        stdenv.cc
        binutils
      ];
    multiPkgs = pkgs: with pkgs; [zlib];
    runScript = "bash";
    profile = ''
      export CUDA_PATH=${pkgs.cudatoolkit}
      # export LD_LIBRARY_PATH=${nvidiaPackage}/lib
      export EXTRA_LDFLAGS="-L/lib -L${nvidiaPackage}/lib"
      export EXTRA_CCFLAGS="-I/usr/include"
    '';
  }).env
