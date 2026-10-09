{
  config,
  lib,
  osConfig,
  pkgs,
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

  # the sites firefly serves, on machines that trust its certificates
  home = osConfig.dotnix.home.ca != null;
  inherit (osConfig.dotnix.home) domain;
in

lib.modules.mkIf osConfig.dotnix.profiles.desktop.enable {
  home = {
    packages = [ browser ];
    sessionVariables.BROWSER = lib.meta.getExe browser;
  };

  programs = {
    chromium = {
      enable = !osConfig.dotnix.profiles.desktop.minimal;
      package = pkgs.ungoogled-chromium;
      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      # pinned in nixbuilds, which keeps them up to date
      extensions = pkgs.chromium-extensions.extensions;
    };

    librewolf = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ];

      # syncs through firefly instead of mozilla's servers
      profiles.main.settings = lib.attrsets.optionalAttrs home {
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

        Preferences."browser.tabs.warnOnClose" = {
          Value = false;
          Status = "locked";
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
              "sponsorBlocker@ajay.app" = "sponsorblock";
              "uBlock0@raymondhill.net" = "ublock-origin";
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
