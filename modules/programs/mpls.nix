{pkgs, ...}: let
  mplsBinary = pkgs.stdenv.mkDerivation {
    pname = "mpls";
    version = "0.4.1";
    src = pkgs.fetchurl {
      url = "https://github.com/mhersson/mpls/releases/download/v0.4.1/mpls_0.4.1_linux_amd64.tar.gz";
      sha256 = "b29df8378f9021e752c1a991735fa049332b5dd3eb63b2ac0c84789369aa5683";
    };
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
      mkdir -p $out/bin
      tar -xzf $src --strip-components=0
    '';
    installPhase = ''
      chmod +x mpls
      mv mpls $out/bin/
    '';
  };
in {
  home.packages = [mplsBinary];
}
