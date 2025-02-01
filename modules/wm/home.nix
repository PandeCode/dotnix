{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wm;
  _bind = mod: key: exec: {inherit mod key exec;};
  mod = _bind "super";
  nomod = _bind "";
in {
  imports = [
    ../programs/rofi.nix
  ];

  options.wm = {
    enable = lib.mkEnableOption "enable wm";
    shared = lib.mkOption {
      default = rec {
        terminal = "wezterm";
        explorer = "nautilus";
        workspace_rules = {
          float =
            # WARN: Copied from DWM, WINTYPE, not sure if they count as classes
            ["DIALOG" "UTILITY" "TOOLBAR" "SPLASH" "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE" "_NET_WM_WINDOW_TYPE_NORMAL"]
            ++ ["title:Blender Preferences" "vimb" "title:Picture-in-picture"];
          ws_1 = ["St" "st" terminal "alacritty" "kitty" "st-256color"];
          ws_2 = ["Browser" "Firefox" "Google-chrome" "Opera"];
          ws_3 = ["ModernGL" "Emacs" "emacs" "neovide" "Code" "Code - Insiders" "Blender"];
          ws_4 = ["hakuneko-desktop" "Unity" "unityhub" "UnityHub" "zoom"];
          ws_5 = ["Spotify" "vlc"];
          ws_6 = ["Mail" "Thunderbird"];
          ws_7 = ["riotclientux.exe" "leagueclient.exe" "Zenity" "zenity" "wine" "wine.exe" "explorer.exe"];
          noblur = ["firefox" "Google-chrome"];
          pin = ["title:Picture-in-picture"];
        };
        startup = [
          #"blueman-applet"
          terminal
          "nm-applet --indicator"
        ];
        bindexec = [
          (mod "Return" "${terminal}")
          (mod "e" "${explorer}")

          (nomod "XF86AudioMute" "_tool_ctrl vol toggle")
          (nomod "XF86AudioPlay" "_tool_ctrl media toggle")
          (nomod "XF86AudioNext" "_tool_ctrl media next")
          (nomod "XF86AudioPrev" "_tool_ctrl media prev")

          (mod "t" "translate-clip.sh")
          (_bind "super shift" "t" "translate-img.sh")
          (_bind "super ctrl" "f" "_tool_riot")
          (mod "n" "swaync-client -t -sw")
          (mod "s" "_tool_search")
          (mod "c" "rofi -show calc")

          (_bind "alt" "space" "rofi -show drun -show-icons")
          (_bind "alt shift" "space" "rofi -show run -show-icons")
        ];
        bindexec_el = [
          (nomod "XF86AudioRaiseVolume" "_tool_ctrl vol up")
          (nomod "XF86AudioLowerVolume" "_tool_ctrl vol down")
          (nomod "XF86AudioMicMute" "_tool_ctrl mic down")
          (nomod "XF86MonBrightnessUp" "_tool_ctrl light up")
          (nomod "XF86MonBrightnessDown" "_tool_ctrl light down")
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    rofi.enable = true;
    programs = {
      kitty.enable = true;
      alacritty.enable = true;
    };

    home.packages = with pkgs; [
      # (import ../../../derivations/beatprints.nix {
      # inherit lib pkgs;
      # pkgs = pkgs-stable;
      # })

      (import ../../derivations/httptap.nix {inherit lib pkgs;})

      (tesseract.override {
        enableLanguages = ["eng"];
      })
    ];
  };
}
