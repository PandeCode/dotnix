{
  pkgs,
  lib,
}:
pkgs.stdenv.mkDerivation {
  pname = "mpls";
  version = "0.8.4";

  src = pkgs.fetchurl {
    url = "https://github.com/mhersson/mpls/releases/download/v0.8.4/mpls_0.8.4_linux_amd64.tar.gz";
    sha256 = "0ms2hb534fhcg4yz7mwgsa0vf8cm8q2g7k7lziv0j6pv50cnp3vd";
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

  meta = {
    description = "Markdown Preview Language Server";
    homepage = "https://github.com/mhersson/mpls";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [];
    mainProgram = "mpls";
    platforms = lib.platforms.all;
  };
}
