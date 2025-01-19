{nixpkgs, ...}: let
  pkgs = nixpkgs;
in rec {
  mkTool = lang: compiler: args: pname: (pkgs.stdenv.mkDerivation {
    inherit pname;
    version = "v0";
    nativeBuildInputs = [pkgs.${compiler}];
    src = ../../tools/${pname}.${lang};
    phases = ["compilePhase" "installPhase"];
    compilePhase = ''
      ${compiler} ${args} $src -o ${pname}
    '';
    installPhase = ''
      mkdir -p $out/bin/
      mv ${pname} $out/bin/
    '';
  });

  mkToolC = mkTool "c" "gcc" "-O3";
  mkToolRust = mkTool "rs" "rustc" "-C opt-level=3";
}
