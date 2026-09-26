{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "c-tools";
  version = "0";

  src = ../../src;

  buildPhase = ''
    runHook preBuild
    for tool in contpid sizes; do
      $CC -std=gnu11 -O3 -flto -o $tool $tool.c
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin contpid sizes
    runHook postInstall
  '';

  meta = {
    description = "contpid and sizes, from src/";
    platforms = lib.platforms.linux;
  };
}
