{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.dwm;
in {
  options.dwm.enable = lib.mkEnableOption "enable dwm";

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
      picom-pijulius
      haskellPackages.greenclip
      xflux
      kdePackages.kdeconnect-kde
      sxhkd
      # barrier

      (st.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "pandecode";
          repo = "st-flexipatch";
          rev = "3000dc1ca3723880b5fe99886dbc1d7798583c2d";
          sha256 = "xkmE9mJDYHdtroegjff9zwEYnKT9zSoOS65BhA2iOQI=";
        };
        buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
      }))
      (dwmblocks.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "pandecode";
          repo = "dwmblocks";
          rev = "30ab13f5a928c9b6d890be2960332821e73601a0";
          sha256 = "9YB56rBbEs5AEe5mkn0k7QhA6uNONmdwzX3XsvvfsFM=";
        };
        inherit (oldAttrs) buildInputs;
      }))
    ];
  };
}
