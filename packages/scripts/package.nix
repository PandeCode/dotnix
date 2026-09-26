{
  lib,
  stdenvNoCC,
  bash,
  lua,
  perl,
  python3,
}:

stdenvNoCC.mkDerivation {
  pname = "scripts";
  version = "0";

  # symlinks point outside the repo
  src = lib.fileset.toSource {
    root = ../../bin;
    fileset = lib.fileset.fileFilter (file: file.type == "regular") ../../bin;
  };

  # for patchShebangs
  buildInputs = [
    bash
    lua
    perl
    python3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin *
    runHook postInstall
  '';

  meta = {
    description = "My scripts from bin/";
    platforms = lib.platforms.linux;
  };
}
