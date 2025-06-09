{
  pkgs,
  config,
  lib,
  sharedConfig,
  ...
}: let
  themes = pkgs.stdenv.mkDerivation {
    name = "rofi-themes-patched";
    src = pkgs.fetchFromGitHub {
      owner = "adi1090x";
      repo = "rofi";
      rev = "b76c16b2b7c465d7b082e11e5210fcd10c6683a7";
      hash = "sha256-R4LmFRjXTo66v8P/fMJee5m1ksuOtJ+VdYleftIM/rk=";
      sparseCheckout = [
        "fonts"
        "files"
      ];
    };

    installPhase = ''
      mkdir -p $out
      sed -i '$d' files/config.rasi

      echo "@theme \"nix\"" | cat - files/config.rasi > temp && mv temp files/config.rasi

      cat >> files/config.rasi << EOF
          kb-accept-alt             : "Shift+Return";
          kb-accept-custom          : "Control+Alt+Return";
          kb-accept-custom-alt      : "Control+Shift+Alt+Return";
          kb-accept-entry           : "Return,KP_Enter";
          kb-cancel                 : "Escape";
          kb-clear-line             : "Control+w";
          kb-custom-10              : "Alt+0";
          kb-custom-11              : "Alt+exclam";
          kb-custom-12              : "Alt+at";
          kb-custom-13              : "Alt+numbersign";
          kb-custom-14              : "Alt+dollar";
          kb-custom-15              : "Alt+percent";
          kb-custom-16              : "Alt+dead_circumflex";
          kb-custom-17              : "Alt+ampersand";
          kb-custom-18              : "Alt+asterisk";
          kb-custom-19              : "Alt+parenleft";
          kb-custom-1               : "Alt+1";
          kb-custom-2               : "Alt+2";
          kb-custom-3               : "Alt+3";
          kb-custom-4               : "Alt+4";
          kb-custom-5               : "Alt+5";
          kb-custom-6               : "Alt+6";
          kb-custom-7               : "Alt+7";
          kb-custom-8               : "Alt+8";
          kb-custom-9               : "Alt+9";
          kb-delete-entry           : "Shift+Delete";
          kb-ellipsize              : "Alt+period";
          kb-mode-complete          : "Control+space";
          kb-mode-next              : "Control+Tab";
          kb-mode-previous          : "Control+ISO_Left_Tab";
          kb-move-char-back         : "Left";
          kb-move-char-forward      : "Right";
          kb-move-end               : "Control+e";
          kb-move-front             : "Control+a";
          kb-move-word-back         : "Control+Left";
          kb-move-word-forward      : "Control+Right";
          kb-page-next              : "Control+l";
          kb-page-prev              : "Control+h";
          kb-primary-paste          : "Control+V,Shift+Insert";
          kb-remove-char-back       : "BackSpace";
          kb-remove-char-forward    : "Delete";
          kb-remove-to-eol          : "";
          kb-remove-to-sol          : "";
          kb-remove-word-back       : "Control+BackSpace";
          kb-remove-word-forward    : "";
          kb-row-down               : "Control+j";
          kb-row-first              : "Home,KP_Home";
          kb-row-last               : "End,KP_End";
          kb-row-left               : "Control+Page_Up";
          kb-row-right              : "Control+Page_Down";
          kb-row-select             : "Control+Return";
          /* kb-row-tab                : "Tab"; */
          kb-row-up                 : "Control+k";
          kb-screenshot             : "Alt+S";
          kb-secondary-paste        : "Control+v,Insert";
          kb-select-10              : "Super+0";
          kb-select-1               : "Super+1";
          kb-select-2               : "Super+2";
          kb-select-3               : "Super+3";
          kb-select-4               : "Super+4";
          kb-select-5               : "Super+5";
          kb-select-6               : "Super+6";
          kb-select-7               : "Super+7";
          kb-select-8               : "Super+8";
          kb-select-9               : "Super+9";
          kb-toggle-case-sensitivity: "grave,dead_grave";
          kb-toggle-sort            : "Alt+grave";
          me-accept-custom          : "Control+MouseDPrimary";
          me-accept-entry           : "MouseDPrimary";
          me-select-entry           : "MousePrimary";
          ml-row-down               : "ScrollDown";
          ml-row-left               : "ScrollLeft";
          ml-row-right              : "ScrollRight";
          ml-row-up                 : "ScrollUp";
      }
      EOF

      cp -r files fonts $out/

      find $out -type f -name colors.rasi -exec \
      sed -i 's|~/.config/rofi/colors/onedark.rasi|~/.config/rofi/nix.rasi|g' {} +
    '';
  };
in {
  home.file = {
    ".local/share/fonts" = {
      source = "${themes}/fonts";
      recursive = true;
    };
    ".local/share/rofi/themes/nix.rasi" = {
      text = ''
        configuration {
          font: "JetBrainsMono Nerd Font 12";
          show-icons: true;
          icon-theme: "Papirus";
          display-drun: "Apps";
          drun-display-format: "{icon} {name}";
          scrollbar: false;
        }

        * {
          background: rgba(30, 30, 40, 0.6);
          foreground: #ffffff;
          border-color: rgba(255, 255, 255, 0.2);
          selected-background: rgba(100, 150, 255, 0.4);
          selected-foreground: #ffffff;
          border-radius: 12px;
          padding: 10px;
          spacing: 5px;
        }

        window {
          location: center;
          width: 600px;
          border: 2px;
        }

        mainbox {
          background-color: transparent;
        }

        inputbar {
          background-color: rgba(50, 50, 60, 0.6);
          padding: 10px;
          border-radius: 12px;
        }

        prompt {
          padding: 0 10px 0 0;
        }

        textbox-prompt-colon {
          expand: false;
          str: ":";
          margin: 0px 4px 0px 0px;
        }

        listview {
          lines: 10;
          columns: 1;
          spacing: 4px;
          fixed-height: false;
          dynamic: true;
        }

        element {
          border: 0;
          padding: 8px;
          background-color: transparent;
        }

        element selected {
          background-color: @selected-background;
          border-radius: 8px;
          text-color: @selected-foreground;
        }

        element-icon {
          size: 1.2em;
          padding: 0 10px 0 0;
        }
      '';
    };
  };

  # home.activation.updateFontsCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   echo "🔄 Rebuilding font cache..."
  #   ${pkgs.fontconfig}/bin/fc-cache -fv
  # '';

  home.packages = with pkgs; [
    (
      writeShellScriptBin "rofi-wifi-menu" (builtins.readFile (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/zbaylin/rofi-wifi-menu/refs/heads/master/rofi-wifi-menu.sh";
        sha256 = "0gilv2q4l7synn1labwzw3bm4xy4h1z2l7kh1jhjyfxn3xpx7fnc";
      }))
    )

    (rofi-wayland.override {plugins = [rofi-emoji rofi-calc rofi-games rofi-power-menu rofi-mpd];})

    rofi-bluetooth
  ];

  programs = {
    rbw = {
      enable = true;
      settings.email = config.programs.git.userEmail;
      package = pkgs.rofi-rbw-wayland;
    };
  };
  xdg.configFile = {
    "rofi" = {
      source = "${themes}/files";
      recursive = true;
    };
    "rofi/nix.rasi".text = let
      c = config.lib.stylix.colors;
    in ''
      * {
          background:     #${c.base00}FF;
          background-alt: #${c.base01}FF;
          foreground:     #${c.base05}FF;
          selected:       #${c.base02}FF;
          active:         #${c.base03}FF;
          urgent:         #${c.base0F}FF;
      }
    '';
  };
}
