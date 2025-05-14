{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.picom;
in {
  options.picom.enable = lib.mkEnableOption "enable picom";

  config = lib.mkIf cfg.enable {
    services.picom = {
      enable = false;
      activeOpacity = 1;
      backend = "xrender"; # "egl", "glx", "xrender", "xr_glx_hybrid"
      vSync = true;
      fade = true;
      shadow = true;
      # package = pkgs.picom-pijulius;

      # package =
      # (picom.overrideAttrs (oldAttrs: {
      #   src = pkgs.fetchFromGitHub {
      #     owner = "";
      #     repo = "";
      #     rev = "";
      #     sha256 = "";
      #   };
      #   inherit (oldAttrs) buildInputs;
      # }))

      # extraArgs = []; #Extra arguments to be passed to the picom executable.	list of string
      # fadeDelta = {}; #Time between fade animation step (in ms).	positive integer, meaning >0
      # fadeExclude = {}; #List of conditions of windows that should not be faded. See `picom(1)` man page for more examples.	list of string
      # fadeSteps = {}; #Opacity change between fade steps (in and out).	pair of integer or floating point number between 0.01 and 1 (both inclusive)
      # inactiveOpacity = {}; #Opacity of inactive windows.	integer or floating point number between 0.1 and 1 (both inclusive)
      # menuOpacity = {}; #Opacity of dropdown and popup menu.	integer or floating point number between 0 and 1 (both inclusive)
      # opacityRules = {}; #Rules that control the opacity of windows, in format PERCENT:PATTERN.	list of string
      # settings = {}; #Picom settings. Use this option to configure Picom settings not exposed in a NixOS option or to bypass one. For the available options see the CONFIGURATION FILES section at `picom(1)`.	libconfig configuration. The format consists of an attributes set (called a group) of settings. Each setting can be a scalar type (boolean, integer, floating point number or string), a list of scalars or a group itself
      # shadowExclude = {}; #List of conditions of windows that should have no shadow. See `picom(1)` man page for more examples.	list of string
      # shadowOffsets = {}; #Left and right offset for shadows (in pixels).	pair of signed integer
      # shadowOpacity = {}; #Window shadows opacity.	integer or floating point number between 0 and 1 (both inclusive)
      # wintypes = {}; #Rules for specific window types.	attribute set
    };
  };
}
