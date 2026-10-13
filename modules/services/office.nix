# office.<domain>: onlyoffice, so word, excel and powerpoint files in
# files.<domain> open and save in the browser. you never go here directly
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.home) domain theme;

  cfg = config.dotnix.services.office;
  inherit (config.services.onlyoffice) package;

  # the editor in dark mode, in your colors
  themed =
    pkgs.runCommand "office-theme"
      {
        nativeBuildInputs = [ pkgs.python3 ];
        colors = builtins.toJSON (
          lib.attrsets.filterAttrs (name: _: lib.strings.hasPrefix "base0" name) theme.colors
        );
        passAsFile = [ "colors" ];
      }
      ''
        mkdir $out
        python3 ${./office-theme.py} \
          ${package}/var/www/onlyoffice/documentserver/web-apps/apps/documenteditor/main/resources/css/app.css \
          "$colorsPath" $out
      '';

  port = 8092;
  secrets = "/var/lib/office-secrets";
in

{
  options.dotnix.services.office = {
    enable = lib.options.mkEnableOption "onlyoffice, editing documents in files.<domain>";

    secretFile = lib.options.mkOption {
      type = lib.types.str;
      default = "${secrets}/jwt";
      readOnly = true;
      description = "The key files.<domain> signs its requests to onlyoffice with.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.dotnix.services.files.enable;
        message = "dotnix.services.office edits files from dotnix.services.files, so it needs that too.";
      }
    ];

    services.onlyoffice = {
      enable = true;
      hostname = "office.${domain}";
      jwtSecretFile = cfg.secretFile;
      securityNonceFile = "${secrets}/nonce.conf";
      # it fetches and saves documents through files.<domain> on localhost
      allowLocalConnections = true;
    };
    # rabbitmq's name server, only for this machine
    services.epmd.listenStream = "127.0.0.1:4369";

    # through caddy the links it makes say https and office.<domain>; asked
    # directly by files.<domain>, they stay on localhost
    services.nginx.appendHttpConfig = ''
      map $http_x_forwarded_proto $office_proto {
        default $http_x_forwarded_proto;
        "" $scheme;
      }
      map $http_x_forwarded_host $office_host {
        default $http_x_forwarded_host;
        "" $host:$server_port;
      }
    '';
    services.nginx.virtualHosts."office.${domain}" = {
      listen = [
        {
          addr = "127.0.0.1";
          inherit port;
        }
      ];
      locations = lib.modules.mkIf (theme != null) {
        "= /dotnix-theme.css".extraConfig = ''
          add_header Cache-Control no-cache;
          alias ${themed}/theme.css;
        '';
        "~ ^(\\/[\\d]+\\.[\\d]+\\.[\\d]+[\\.|-][\\w]+)?\\/themes\\.json$".extraConfig = ''
          default_type application/json;
          alias ${themed}/themes.json;
        '';
        # each editor's page links it
        "~ ^(\\/[\\d]+\\.[\\d]+\\.[\\d]+[\\.|-][\\w]+)?\\/(web-apps|sdkjs|sdkjs-plugins|fonts|dictionaries)(\\/.*)$".extraConfig =
          ''
            sub_filter '</head>' '<link rel="stylesheet" href="/dotnix-theme.css"></head>';
          '';
      };
      extraConfig = lib.modules.mkForce ''
        rewrite ^\/OfficeWeb(\/apps\/.*)$ /${package.version}/web-apps$1 redirect;
        rewrite ^(\/web-apps\/apps\/(?!api\/).*)$ /${package.version}$1 redirect;

        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $office_host;
        proxy_set_header X-Forwarded-Proto $office_proto;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };

    # made once on this machine, so there is nothing to put in sops
    systemd.services.office-secrets = {
      description = "Make the secrets onlyoffice and files.${domain} share";
      wantedBy = [ "multi-user.target" ];
      before = [
        "nginx.service"
        "onlyoffice-docservice.service"
        "filebrowser-quantum.service"
      ];
      requiredBy = [
        "nginx.service"
        "onlyoffice-docservice.service"
        "filebrowser-quantum.service"
      ];
      script = ''
        umask 027
        if [ ! -s jwt ]; then
          od -An -tx1 -N32 /dev/urandom | tr -d ' \n' >jwt
        fi
        if [ ! -s nonce.conf ]; then
          printf 'set $secure_link_secret "%s";\n' "$(od -An -tx1 -N32 /dev/urandom | tr -d ' \n')" >nonce.conf
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "office-secrets";
        StateDirectoryMode = "0750";
        WorkingDirectory = secrets;
        Group = "onlyoffice";
      };
    };

    dotnix.home.sites.office = {
      inherit port;
      # it is opened from files.<domain>, so it stays off the start page
      listed = false;
    };
  };
}
