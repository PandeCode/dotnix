{pkgs, ...}: let
  mpls = pkgs.stdenv.mkDerivation {
    pname = "mpls";
    version = "0.6.0";
    src = pkgs.fetchurl {
      url = "https://github.com/mhersson/mpls/releases/download/v0.6.0/mpls_0.6.0_linux_amd64.tar.gz";
      sha256 = "93cb6ef1491ccb71abdecfb8e27045cbacf2eba191513a28957f94010d328fa5";
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
  home.packages = [mpls];
}
