{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.beatprints;
  spotify_client_secret = "secret";
  spotify_client_id = "id";
in {
  options.beatprints.enable = lib.mkEnableOption "enable beatprints";

  config = lib.mkIf cfg.enable {
    home = {
      file.".config/BeatPrints/config.toml".text =
        /*
        toml
        */
        ''
          [general]
          search_limit = 7
          output_directory = "/home/${config.home.username}/Pictures/BeatPrints/"

          [credentials]
          client_id = "${spotify_client_id}"
          client_secret = "${spotify_client_secret}"'';
      packages = with pkgs;
      with python3Packages; [
        (
          buildPythonPackage rec {
            pname = "BeatPrints";
            version = "1.1.3";
            format = "wheel";

            src = builtins.fetchurl {
              url = "https://files.pythonhosted.org/packages/e5/13/9dd2ea8097217c292e590299f152e6aa2da974f97bed78ec18eb9d10d73a/beatprints-1.1.3-py3-none-any.whl";
              sha256 = "1c4qkkiiy75jigq948wwwrm3gwixqh6aj2l6vcbyk8vqv1w0b482";
            };
            meta = with lib; {
              description = "☕ BeatPrints, create eye-catching, Pinterest-style music posters effortlessly.";
              license = licenses.mit;
              homepage = "https://github.com/TrueMyst/BeatPrints";
              mainProgram = "beatprints";
            };

            propagatedBuildInputs = [
              python3Packages.requests
              python3Packages.pillow
              python3Packages.fonttools
              python3Packages.questionary
              python3Packages.rich
              python3Packages.toml
              python3Packages.numpy
              (buildPythonPackage {
                pname = "lrclibapi";
                version = "0.3.1";
                format = "wheel";
                src = builtins.fetchurl {
                  url = "https://files.pythonhosted.org/packages/b9/2d/e8ecdb1676b97e247f3e3da11f2ef0a6bb51fb4b4d4e93a5440be77f368d/lrclibapi-0.3.1-py3-none-any.whl";
                  sha256 = "1iy8kcs3n69q8v64z1n1w518hmx9lzvwz6p1dx11ylkm23xdqw9c";
                };
              })
              (buildPythonPackage {
                pname = "pylette";
                version = "4.0.0";
                format = "wheel";
                src = builtins.fetchurl {
                  url = "https://files.pythonhosted.org/packages/70/24/23687569b79f076259c538df3c4e422d01e102020d359e76c5b40bf601c5/pylette-4.0.0-py3-none-any.whl";
                  sha256 = "0l799aaw98v8y6dnqlplhp88dy7yw7vxz0gl1qcaqfz9qqxjns3d";
                };
              })
            ];

            buildInputs = propagatedBuildInputs;
            nativeBuildInputs = propagatedBuildInputs;
          }
        )
      ];
    };
  };
}
