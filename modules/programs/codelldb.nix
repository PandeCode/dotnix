{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.codelldb;
in {
  options.codelldb.enable = lib.mkEnableOption "enables codelldb";
  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.stdenv.mkDerivation {
        pname = "codelldb";
        version = "1.11.1";

        nativeBuildInputs = [pkgs.unzip];
        src = pkgs.fetchurl {
          url = "https://github.com/vadimcn/codelldb/releases/download/v1.11.1/codelldb-linux-x64.vsix";
          sha256 = "73ca1562286b24a1da1cd336b950599f0491f8eb447f1630b4efd073d2cc0651";
        };
        phases = ["unpackPhase" "installPhase"];
        unpackPhase = ''
          mkdir -p $out/bin
          unzip $src
        '';
        installPhase = ''
          chmod +x extension/adapter/codelldb
          mv extension $out/
          ln -s $out/extension/adapter/codelldb $out/bin/codelldb
        '';
      })
    ];
  };
}
