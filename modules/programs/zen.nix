{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.zen-browser.homeModules.twilight];

  # stylix.targets.zen-browser.profileNames = ["shawn"];

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs.firefoxpwa];
    # profiles = {
    #   "shawn".search.engines = {
    #     nix-packages = {
    #       name = "Nix Packages";
    #       urls = [
    #         {
    #           template = "https://search.nixos.org/packages";
    #           params = [
    #             {
    #               name = "type";
    #               value = "packages";
    #             }
    #             {
    #               name = "query";
    #               value = "{searchTerms}";
    #             }
    #           ];
    #         }
    #       ];
    #
    #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #       definedAliases = ["@np"];
    #     };
    #
    #     nixos-wiki = {
    #       name = "NixOS Wiki";
    #       urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
    #       iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
    #       definedAliases = ["@nw"];
    #     };
    #
    #     bing.metaData.hidden = true;
    #     google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
    #   };
    # };
    policies = {
      Preferences = let
        mkLockedAttrs = builtins.mapAttrs (_: value: {
          Value = value;
          Status = "locked";
        });
      in
        mkLockedAttrs
        {
          "browser.tabs.warnOnClose" = false;
        };

      ExtensionSettings = let
        mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
          installation_mode = "force_installed";
        });
      in
        mkExtensionSettings {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
          "sponsorBlocker@ajay.app" = "sponsorblock";
          "uBlock0@raymondhill.net" = "ublock-origin";
        };

      # https://mozilla.github.io/policy-templates/
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
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

  xdg.mimeApps = let
    value = let
      zen-browser = inputs.zen-browser.packages.${pkgs.system}.twilight; # or twilight
    in
      zen-browser.meta.desktopFileName;

    associations = builtins.listToAttrs (map (name: {
        inherit name value;
      }) [
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-html"
        "application/x-extension-xht"
        "application/x-extension-htm"
        "x-scheme-handler/unknown"
        "x-scheme-handler/mailto"
        "x-scheme-handler/chrome"
        "x-scheme-handler/about"
        "x-scheme-handler/https"
        "x-scheme-handler/http"
        "application/xhtml+xml"
        "application/json"
        "text/plain"
        "text/html"
      ]);
  in {
    associations.added = associations;
    defaultApplications = associations;
  };
}
