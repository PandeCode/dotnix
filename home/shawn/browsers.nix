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

  crx =
    { id, sha256, ... }:
    pkgs.fetchurl {
      name = "${id}.crx";
      url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${lib.versions.major pkgs.ungoogled-chromium.version}&x=id%3D${id}%26installsource%3Dondemand%26uc";
      sha256 = lib.strings.removePrefix "sha256:" sha256;
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
      extensions =
        let
          ublock = rec {
            id = "hifpfkolgdolnmfmncmfocfiiaofjikk";
            version = "1.72.2";
            crxPath = pkgs.fetchurl {
              name = "${id}.crx";
              url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
              sha256 = "0cz5fi9gnynja34cjv709a0nk0ma5vgax27zqfqpd3glw72cl16i";
            };
          };
        in
        [ ublock ]
        ++ map (e: {
          inherit (e) id version;
          crxPath = crx e;
        }) (builtins.attrValues (import ./chromium-extensions.nix));
    };

    librewolf = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ];

      profiles.main.search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
        engines = {
          bing.metaData.hidden = true;
          # built-in engines take one extra alias only
          google.metaData.alias = "@g";
          "Nix Packages" = engine "@np" "https://search.nixos.org/packages" [
            unstable
            (searchTerms "query")
          ];
          "Nix Options" = engine "@no" "https://search.nixos.org/options" [
            unstable
            (searchTerms "query")
          ];
          "NixOS Wiki" = engine "@nw" "https://wiki.nixos.org/w/index.php" [ (searchTerms "search") ];
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
            };

        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableAppUpdate = true;

        DisableBuiltinPDFViewer = true;
        DisableFirefoxAccounts = true;
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
