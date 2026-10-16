{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkForce mkIf mkMerge;
  inherit (lib.strings) optionalString;

  lines = parts: lib.strings.concatLines (lib.lists.filter (s: s != "") parts);

  ppd = osConfig.services.power-profiles-daemon;
  powerprofilesctl = lib.meta.getExe' ppd.package "powerprofilesctl";
  brightnessctl = lib.meta.getExe pkgs.brightnessctl;
  playerctl = lib.meta.getExe pkgs.playerctl;

  # the profile to go back to, so a mode doesn't leave balanced behind
  saved = "\${XDG_RUNTIME_DIR:-/tmp}/mode-power-profile";
  profile = name: ''
    ${powerprofilesctl} get >"${saved}"
    ${powerprofilesctl} set ${name}
  '';
  restoreProfile = ''
    ${powerprofilesctl} set "$(cat "${saved}" 2>/dev/null || echo balanced)"
    rm -f "${saved}"
  '';

  # pausing every device keeps syncthing running but quiet, and it sticks
  # until resumed
  syncthing = osConfig.services.syncthing;
  syncthingRest = action: ''
    key=$(sed -n 's:.*<apikey>\(.*\)</apikey>.*:\1:p' "${syncthing.configDir}/config.xml")
    ${lib.meta.getExe pkgs.curl} -fsS -X POST -H "X-API-Key: $key" \
      "http://${syncthing.guiAddress}/rest/system/${action}" || true
  '';
  hasSyncthing = syncthing.enable && syncthing.user == osConfig.dotnix.user;

  # rofi remakes its theme from the stylix colors and font
  rofi = "rm -f /tmp/launcher.rasi";

  quiet = {
    on = "disable_notifications.sh";
    off = "enable_notifications.sh";
  };
in

mkIf osConfig.dotnix.profiles.desktop.enable {
  dotnix.modes = mkMerge [
    {
      presentation = {
        # a plain font for people who aren't used to opendyslexic
        config.stylix.fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font Mono";
          };
          sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          serif = {
            package = pkgs.noto-fonts;
            name = "Noto Serif";
          };
        };

        # no popups on the projector
        on = ''
          ${quiet.on}
          ${rofi}
        '';
        off = ''
          ${quiet.off}
          ${rofi}
        '';
      };

      # one light, the light half of onedark, for the sun or a bright room
      daylight = {
        config.stylix = {
          polarity = mkForce "light";
          base16Scheme = mkForce {
            system = "base16";
            name = "One Light";
            author = "Daniel Pfeifer (http://github.com/purpleKarrot)";
            variant = "light";
            palette = {
              base00 = "#fafafa";
              base01 = "#f0f0f1";
              base02 = "#e5e5e6";
              base03 = "#a0a1a7";
              base04 = "#696c77";
              base05 = "#383a42";
              base06 = "#202227";
              base07 = "#090a0b";
              base08 = "#ca1243";
              base09 = "#d75f00";
              base0A = "#c18401";
              base0B = "#50a14f";
              base0C = "#0184bc";
              base0D = "#4078f2";
              base0E = "#a626a4";
              base0F = "#986801";
            };
          };
        };
        on = rofi;
        off = rofi;
      };

      # for tired eyes or a shared screen
      big = {
        config.stylix.fonts.sizes = {
          applications = 15;
          desktop = 13;
          popups = 13;
          terminal = 16;
        };
        on = rofi;
        off = rofi;
      };

      # the music stays paused after; it's easy to start again
      focus = {
        on = ''
          ${quiet.on}
          ${playerctl} --all-players pause || true
        '';
        inherit (quiet) off;
      };
    }

    (mkIf osConfig.dotnix.profiles.laptop.enable {
      battery = {
        on = lines [
          (optionalString ppd.enable (profile "power-saver"))
          "${brightnessctl} --save set 30%"
          (optionalString hasSyncthing (syncthingRest "pause"))
        ];
        off = lines [
          (optionalString ppd.enable restoreProfile)
          "${brightnessctl} --restore"
          (optionalString hasSyncthing (syncthingRest "resume"))
        ];
      };
    })

    (mkIf osConfig.dotnix.profiles.gaming.enable {
      gaming = {
        on = lines [
          quiet.on
          (optionalString ppd.enable (profile "performance"))
        ];
        off = lines [
          quiet.off
          (optionalString ppd.enable restoreProfile)
        ];
      };
    })
  ];
}
