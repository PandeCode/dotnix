{
  config,
  lib,
  osConfig,
  pkgs,
  self,
  ...
}:

let
  browser = pkgs.writeShellApplication {
    name = "browser";
    runtimeInputs = [ pkgs.procps ];
    text = builtins.readFile ../../bin/browser.sh;
  };

  engine = alias: template: params: {
    urls = [ { inherit template params; } ];
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    definedAliases = [ alias ];
  };

  searchTerms = name: {
    inherit name;
    value = "{searchTerms}";
  };

  unstable = {
    name = "channel";
    value = "unstable";
  };

  # starts hermes for the firenvim extension
  firenvimHost = lib.lists.optional osConfig.programs.hermes.enable osConfig.programs.hermes.firenvimHost;

  # alt+d closes the tab, from an extension of mine
  browserKeys = self.packages.${pkgs.stdenv.hostPlatform.system}.browser-keys;

  firenvim = command: key: {
    inherit command key;
    firefox = "firenvim@lacamb.re";
    chromium = "egpjdkipkomnmjhjmdamaniclmdlobbo";
  };

  # extension shortcuts on keys the browsers keep for themselves. firenvim
  # gets the ones nvim needs, and outside a firenvim frame they do what the
  # browser would have done
  shortcuts = [
    (firenvim "send_C-n" "Ctrl+N")
    (firenvim "send_C-t" "Ctrl+T")
    (firenvim "send_C-w" "Ctrl+W")
    (firenvim "send_CS-n" "Ctrl+Shift+N")
    (firenvim "send_CS-t" "Ctrl+Shift+T")
    (firenvim "send_CS-w" "Ctrl+Shift+W")
    # alt+d used to focus the address bar, ctrl+l still does
    {
      command = "close-tab";
      key = "Alt+D";
      firefox = browserKeys.firefoxId;
      chromium = browserKeys.chromiumId;
    }
  ];

  # extension shortcuts live in profile state that the browser rewrites, so
  # they are merged in on each switch while the browser is closed (its lock is
  # gone), and the file is only replaced when something changed
  setShortcuts = pkgs.writeShellScript "set-shortcuts" ''
    jq=${lib.meta.getExe pkgs.jq}
    shortcuts='${builtins.toJSON shortcuts}'

    # merge FILE LOCK FILTER: run the jq filter over FILE unless LOCK exists.
    # it only warns, so a browser's state never stops a switch
    merge() {
      [ -e "$1" ] || return 0
      if [ -L "$2" ] || [ -e "$2" ]; then
        echo "shortcuts: $1 is in use, close the browser and switch again" >&2
        return 0
      fi
      if ! "$jq" -c --argjson shortcuts "$shortcuts" "$3" "$1" > "$1.tmp"; then
        rm -f "$1.tmp"
        echo "shortcuts: can't read $1, left alone" >&2
        return 0
      fi
      if ${pkgs.diffutils}/bin/cmp -s "$1" "$1.tmp"; then
        rm "$1.tmp"
      else
        mv "$1.tmp" "$1"
      fi
    }

    # librewolf: user-set shortcuts in extension-settings.json, one entry per
    # command name with a precedence list of extensions
    librewolf=$HOME/.librewolf/main
    [ -d "$librewolf" ] && [ ! -e "$librewolf/extension-settings.json" ] &&
      echo '{"version":4}' > "$librewolf/extension-settings.json"
    merge "$librewolf/extension-settings.json" "$librewolf/lock" '
      .commands //= {}
      | reduce $shortcuts[] as $s (.;
          .commands[$s.command].precedenceList =
            ([.commands[$s.command].precedenceList[]? | select(.id != $s.firefox)]
             + [{id: $s.firefox, installDate: 0,
                 value: {shortcut: $s.key}, enabled: true}]))
    '

    # chromium: extensions.commands, keyed by platform and accelerator. it
    # won't take an extension's suggested key when the browser uses it
    chromium=$HOME/.config/chromium
    merge "$chromium/Default/Preferences" "$chromium/SingletonLock" '
      .extensions.commands //= {}
      | reduce $shortcuts[] as $s (.;
          .extensions.commands["linux:" + $s.key] = {
            command_name: $s.command,
            extension: $s.chromium,
            global: false
          })
    '
  '';

  # the sites firefly serves, on machines that trust its certificates
  home = osConfig.dotnix.home.ca != null;
  inherit (osConfig.dotnix.home) domain;
in

lib.modules.mkIf osConfig.dotnix.profiles.desktop.enable {
  home = {
    packages = [ browser ];
    sessionVariables.BROWSER = lib.meta.getExe browser;
    activation.browserShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${setShortcuts}
    '';
  };

  programs = {
    chromium = {
      enable = !osConfig.dotnix.profiles.desktop.minimal;
      package = pkgs.ungoogled-chromium;
      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      # pinned in nixbuilds, which keeps them up to date
      extensions = pkgs.chromium-extensions.extensions ++ [
        {
          id = browserKeys.chromiumId;
          crxPath = browserKeys.crx;
          inherit (browserKeys) version;
        }
      ];
      nativeMessagingHosts = firenvimHost;
    };

    librewolf = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ] ++ firenvimHost;

      profiles.main.settings = {
        # browser-keys is mine and not signed by mozilla
        "xpinstall.signatures.required" = false;
      }
      # syncs through firefly instead of mozilla's servers
      // lib.attrsets.optionalAttrs home {
        "identity.fxaccounts.enabled" = true;
        "identity.sync.tokenserver.uri" = "https://firefox.${domain}/1.0/sync/1.5";
      };

      profiles.main.search = {
        force = true;
        # firefly's searxng, or duckduckgo without it; @d is duckduckgo either way
        default = if home then "SearXNG" else "ddg";
        privateDefault = if home then "SearXNG" else "ddg";
        engines = {
          bing.metaData.hidden = true;
          # built-in engines take one extra alias only
          google.metaData.alias = "@g";
          ddg.metaData.alias = "@d";
          "Nix Packages" = engine "@np" "https://search.nixos.org/packages" [
            unstable
            (searchTerms "query")
          ];
          "Nix Options" = engine "@no" "https://search.nixos.org/options" [
            unstable
            (searchTerms "query")
          ];
          "NixOS Wiki" = engine "@nw" "https://wiki.nixos.org/w/index.php" [ (searchTerms "search") ];
        }
        // lib.attrsets.optionalAttrs home {
          SearXNG = {
            urls = [
              {
                template = "https://search.${domain}/search";
                params = [ (searchTerms "q") ];
              }
              {
                template = "https://search.${domain}/autocompleter";
                type = "application/x-suggestions+json";
                params = [ (searchTerms "q") ];
              }
            ];
            icon = "https://search.${domain}/favicon.ico";
            definedAliases = [ "@s" ];
          };
          Readeck = {
            urls = [
              {
                template = "https://read.${domain}/bookmarks";
                params = [
                  {
                    name = "bf";
                    value = "1";
                  }
                  (searchTerms "search")
                ];
              }
            ];
            definedAliases = [ "@rd" ];
          };
        };
      };

      # https://mozilla.github.io/policy-templates/
      policies = {
        # librewolf keeps its own list of CAs, apart from the system's
        Certificates.Install = lib.lists.optional (
          osConfig.dotnix.home.ca != null
        ) "${osConfig.dotnix.home.ca}";

        Preferences = {
          "browser.tabs.warnOnClose" = {
            Value = false;
            Status = "locked";
          };
          # open and save dialogs through the portal, so yazi
          "widget.use-xdg-desktop-portal.file-picker" = {
            Value = 1;
            Status = "default";
          };
        };

        ExtensionSettings =
          builtins.mapAttrs
            (_: slug: {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
              installation_mode = "force_installed";
              updates_disabled = true;
            })
            {
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
              # nvim in text boxes and in typst.app's editor
              "firenvim@lacamb.re" = "firenvim";
              "sponsorBlocker@ajay.app" = "sponsorblock";
              "uBlock0@raymondhill.net" = "ublock-origin";
            }
          // {
            ${browserKeys.firefoxId} = {
              install_url = "file://${browserKeys.xpi}";
              installation_mode = "force_installed";
            };
          }
          // lib.attrsets.optionalAttrs home {
            # saves the page to read.<domain>
            "readeck@readeck.com" = "readeck";
          };

        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableAppUpdate = true;

        DisableBuiltinPDFViewer = true;
        DisableFirefoxAccounts = !home;
        DisableFirefoxScreenshots = true;
        DisableForgetButton = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisablePasswordReveal = true;
        DisableProfileImport = true;
        DisableProfileRefresh = true;
        DisableSetDesktopBackground = true;

        BlockAboutConfig = false;
        BlockAboutProfiles = true;
        BlockAboutSupport = true;

        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisplayMenuBar = "never";
        DontCheckDefaultBrowser = true;
        HardwareAcceleration = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
    };
  };

  xdg = {
    desktopEntries.browser = {
      name = "Browser";
      exec = "${lib.meta.getExe browser} %u";
      terminal = false;
      type = "Application";
    };

    mimeApps.defaultApplications = lib.attrsets.genAttrs [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ] (_: "browser.desktop");
  };
}
