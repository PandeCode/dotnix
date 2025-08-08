{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [../x/os.nix];

  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm.overrideAttrs (oldAttrs: {
      src = ../../../submodules/dwm-flexipatch;
      # src = inputs.dwm-flexipatch;
      #   pkgs.fetchFromGitHub {
      #     owner = "pandecode";
      #     repo = "dwm-flexipatch";
      #     rev = "b04a46a679e5bbd864516e04dcee50c814816607";
      #     sha256 = "hNr5Vu4KpNE91WncxAF3WNMNPzXRxGoIUoA3aILKk4Y=";
      #   };

      nativeBuildInputs =
        oldAttrs.nativeBuildInputs ++ [pkgs.pkg-config];

      buildInputs =
        oldAttrs.buildInputs
        ++ (with pkgs; [
          imlib2Full
          yajl

          xorg.libX11
          xorg.libXft
          xorg.libXinerama
          xorg.xorgproto
          xorg.libXfixes
          xorg.libXi

          fontconfig
          freetype
          yajl
          imlib2Full
        ]);
    });
  };

  # environment.systemPackages = with pkgs; [
  #   (st.overrideAttrs (oldAttrs: {
  #     src = pkgs.fetchFromGitHub {
  #       owner = "pandecode";
  #       repo = "st-flexipatch";
  #       rev = "3000dc1ca3723880b5fe99886dbc1d7798583c2d";
  #       sha256 = "xkmE9mJDYHdtroegjff9zwEYnKT9zSoOS65BhA2iOQI=";
  #     };
  #     buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
  #   }))
  #   (dwmblocks.overrideAttrs (oldAttrs: {
  #     src = pkgs.fetchFromGitHub {
  #       owner = "pandecode";
  #       repo = "dwmblocks";
  #       rev = "30ab13f5a928c9b6d890be2960332821e73601a0";
  #       sha256 = "9YB56rBbEs5AEe5mkn0k7QhA6uNONmdwzX3XsvvfsFM=";
  #     };
  #     inherit (oldAttrs) buildInputs;
  #   }))
  # ];
}
