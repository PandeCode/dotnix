{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.module;
in {
  options.module.enable = lib.mkEnableOption "enable module";

  config = lib.mkIf cfg.enable {
    services.xserver.windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "pandecode";
          repo = "dwm-flexipatch";
          rev = "b04a46a679e5bbd864516e04dcee50c814816607";
          sha256 = "hNr5Vu4KpNE91WncxAF3WNMNPzXRxGoIUoA3aILKk4Y=";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      (st.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "pandecode";
          repo = "st-flexipatch";
          rev = "3000dc1ca3723880b5fe99886dbc1d7798583c2d";
          sha256 = "xkmE9mJDYHdtroegjff9zwEYnKT9zSoOS65BhA2iOQI=";
        };
        buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
      }))
    ];
  };
}
