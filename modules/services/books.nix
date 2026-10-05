# books.<domain>: kavita, your epubs, pdfs and comics in the browser, and
# over opds for reader apps. drop books in the books folder
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;
  inherit (config.dotnix.home) theme;

  cfg = config.dotnix.services.books;
  kavita = config.services.kavita;

  port = 8087;
  url = "https://books.${config.dotnix.home.domain}";
  token = "${kavita.dataDir}/token-key";

  # its themes put their variables on a class it gives the body
  css = pkgs.writeText "dotnix.css" ''
    ${theme.import}
    :root .bg-dotnix {
      --theme-color: var(--base00);
      --bs-body-bg: var(--base00);
      --body-text-color: var(--base05);
      --text-muted-color: var(--base04);
      --primary-color: var(--base0D);
      --primary-color-dark-shade: color-mix(in oklab, var(--base0D), var(--base00) 20%);
      --primary-color-darker-shade: color-mix(in oklab, var(--base0D), var(--base00) 35%);
      --primary-color-darkest-shade: color-mix(in oklab, var(--base0D), var(--base00) 55%);
      --error-color: var(--base08);
      --error-accent-color: var(--base08);
      --warning-color: var(--base0A);
      --body-font-family: var(--font);
      --brand-font-family: var(--font);
      --elevation-layer0-dark-solid: var(--base00);
      --elevation-layer1-dark-solid: var(--base01);
      --elevation-layer2-dark-solid: var(--base01);
      --elevation-layer3-dark-solid: var(--base01);
      --elevation-layer4-dark-solid: var(--base02);
      --elevation-layer5-dark-solid: var(--base02);
      --elevation-layer6-dark-solid: var(--base02);
      --elevation-layer7-dark-solid: var(--base02);
      --elevation-layer8-dark-solid: var(--base03);
      --elevation-layer9-dark-solid: var(--base03);
      --colorscape-primary-color: var(--base01);
      --colorscape-lighter-color: var(--base02);
      --colorscape-darker-color: var(--base00);
      --colorscape-complementary-color: var(--base02);
      --colorscape-primary-default-color: var(--base01);
      --colorscape-lighter-default-color: var(--base02);
      --colorscape-darker-default-color: var(--base00);
      --colorscape-complementary-default-color: var(--base02);
      --navbar-bg-color: var(--base00);
      --navbar-text-color: var(--base05);
      --navbar-fa-icon-color: var(--base05);
      --nav-header-bg-color: var(--base01);
      --nav-header-text-color: var(--base06);
      --nav-tab-border-color: var(--base0D);
      --side-nav-text-color: var(--base05);
      --side-nav-hover-bg-color: var(--base01);
      --side-nav-header-text-color: var(--base06);
      --input-bg-color: var(--base01);
      --input-bg-readonly-color: var(--base02);
      --input-text-color: var(--base05);
      --input-placeholder-color: var(--base04);
      --input-border-color: var(--base02);
      --input-focused-border-color: var(--base0D);
      --btn-primary-text-color: var(--base00);
      --btn-primary-hover-text-color: var(--base00);
      --btn-secondary-bg-color: var(--base02);
      --btn-secondary-border-color: var(--base02);
      --btn-secondary-text-color: var(--base05);
      --btn-disabled-bg-color: var(--base01);
      --btn-disabled-border-color: var(--base02);
      --modal-bg-color: var(--base01);
      --drawer-bg-color: var(--base01);
      --drawer-text-color: var(--base05);
      --dropdown-item-bg-color: var(--base01);
      --popover-body-bg-color: var(--base01);
      --popover-bg-color: var(--base01);
      --popover-border-color: var(--base02);
      --accordion-header-text-color: var(--base0D);
      --accordion-header-collapsed-text-color: var(--base0D);
      --accordion-header-bg-color: var(--base01);
      --accordion-header-collapsed-bg-color: var(--base01);
      --accordion-body-bg-color: var(--base01);
      --accordion-active-body-bg-color: var(--base01);
      --breadcrumb-bg-color: var(--base01);
      --card-hover-bg-color: var(--base02);
      --list-group-hover-bg-color: var(--base01);
      --search-list-group-item-bg-color: var(--base01);
      --event-widget-bg-color: var(--base00);
      --event-widget-item-bg-color: var(--base01);
      --login-card-bg-color: var(--base01);
      --setting-header-text-color: var(--base06);
      --pref-side-nav-header-text-color: var(--base06);
      --toast-success-bg-color: var(--base0B);
      --toast-error-bg-color: var(--base08);
      --toast-info-bg-color: var(--base0C);
      --toast-warning-bg-color: var(--base0A);
      --hr-color: var(--base02);
      --label-card-value-color: var(--base05);
      --accent-text-color: var(--base04);
    }
    /* it names its font outright on the body */
    body.bg-dotnix {
      font-family: var(--font);
    }
  '';

  library = builtins.toJSON {
    name = "Books";
    # epub metadata, then the folder names
    type = 2;
    folders = [ cfg.folder ];
    folderWatching = true;
    includeInDashboard = true;
    includeInSearch = true;
    manageCollections = true;
    manageReadingLists = true;
    allowScrobbling = false;
    allowMetadataMatching = false;
    enableMetadata = true;
    # archives, epub, pdf, images
    fileGroupTypes = [
      1
      2
      3
      4
    ];
    excludePatterns = [ ];
    defaultLanguage = "";
  };

  # kavita has no setup but its own api: the first user, the library, the
  # theme and its settings
  seed = pkgs.writeShellApplication {
    name = "books-seed";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.coreutils
    ];
    text = ''
      api=http://127.0.0.1:${toString port}/api
      for _ in $(seq 60); do
        curl -sf "$api/health" >/dev/null && break
        sleep 1
      done

      login=$(jq -n --arg p "$(cat "$CREDENTIALS_DIRECTORY/password")" '{username: "${user}", password: $p}')
      # the first user is the admin; later it is only a login
      curl -sf -H 'Content-Type: application/json' -d "$login" "$api/Account/register" >/dev/null || true
      if ! auth=$(curl -sf -H 'Content-Type: application/json' -d "$login" "$api/Account/login"); then
        echo "the password was changed in kavita, so it no longer matches the secret" >&2
        exit 0
      fi
      bearer="Authorization: Bearer $(jq -r .token <<<"$auth")"
      get() { curl -sf -H "$bearer" "$api/$1"; }
      post() { curl -sf -H "$bearer" -H 'Content-Type: application/json' -d "$2" "$api/$1" >/dev/null; }

      ${lib.strings.optionalString (theme != null) ''
        if ! get Theme | jq -e '.[] | select(.name == "dotnix")' >/dev/null; then
          id=$(curl -sf -H "$bearer" -F "formFile=@${css};filename=dotnix.css" "$api/Theme/upload-theme" | jq .id)
          post Theme/update-default "{\"themeId\": $id}"
          theme=$(get Theme | jq -c '.[] | select(.name == "dotnix")')
          post Users/update-preferences "$(get Users/get-preferences | jq --argjson t "$theme" '.theme = $t')"
        fi
        # it reads the file on every load, so a new theme needs no upload
        install -m 640 -o ${kavita.user} -g ${kavita.user} ${css} ${kavita.dataDir}/config/themes/dotnix.css
      ''}

      if [ "$(get Library/libraries | jq length)" = 0 ]; then
        post Library/create '${library}'
      fi

      # no anonymous stats to kavita's servers
      post Settings "$(get Settings | jq '.allowStatCollection = false | .hostName = "${url}"')"
    '';
  };
in

{
  options.dotnix.services.books = {
    enable = mkEnableOption "kavita, at books.<domain>";

    folder = mkOption {
      type = types.str;
      default =
        if config.dotnix.services.files.enable then
          "${config.dotnix.services.files.folder}/books"
        else
          "/srv/books";
      defaultText = lib.literalExpression ''"''${files.folder}/books" with dotnix.services.files, else "/srv/books"'';
      description = "Where the books are. Inside the shared folder, you can drop them in over smb.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Your password, read at run time, so a secret's path; the user is
        dotnix.user. It is set once, when the user is made. There is no
        library without it.
      '';
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.kavita = {
      enable = true;
      tokenKeyFile = token;
      settings = {
        Port = port;
        IpAddresses = "127.0.0.1";
      };
    };

    # signs its logins; made once and kept
    systemd.services.kavita-token = {
      description = "Make the key Kavita signs logins with";
      requiredBy = [ "kavita.service" ];
      before = [ "kavita.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        UMask = "0077";
      };
      script = ''
        [ -s ${token} ] || ${pkgs.coreutils}/bin/head -c 64 /dev/urandom | ${pkgs.coreutils}/bin/base64 -w0 >${token}
      '';
    };

    systemd.services.books-seed = {
      description = "Set up Kavita's user, library and theme";
      wantedBy = [ "kavita.service" ];
      after = [ "kavita.service" ];
      partOf = [ "kavita.service" ];
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = "password:${cfg.passwordFile}";
        ExecStart = lib.meta.getExe seed;
      };
    };

    # yours to fill, kavita's to read
    systemd.tmpfiles.rules = [ "d ${cfg.folder} 2770 ${user} users -" ];
    users.users.${kavita.user}.extraGroups = [ "users" ];

    dotnix = {
      home.sites.books = { inherit port; };
      backup.paths = [ "${kavita.dataDir}/config" ];
    };
  };
}
