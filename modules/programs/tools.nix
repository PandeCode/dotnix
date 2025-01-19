{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.tools;
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
in {
  options.tools.enable = lib.mkEnableOption "enable tools";

  config = lib.mkIf cfg.enable {
    home.packages = [
      (mkToolC "strdist")
      (mkToolRust "zellij_ping")
    ];
  };
}
