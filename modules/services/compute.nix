# compute.<domain>: jupyterhub, notebooks in the browser like ondemand. log
# in with your login password and your own jupyterlab starts as you, with
# python, sagemath and octave. idle kernels stop after an hour and the whole
# server after two, so nothing sits on memory or the gpu
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix) user;
  inherit (config.dotnix.home) theme;

  cfg = config.dotnix.services.compute;
  files = config.dotnix.services.files;

  # the proxy, its api and the hub behind it
  port = 8095;
  proxyApiPort = 8096;
  hubPort = 8097;

  home = config.users.users.${user}.home;
  # in the shared folder when there is one, so files.<domain> and smb show them
  notebooks = if files.enable then "${files.folder}/notebooks" else home;

  python = pkgs.python3.withPackages (
    ps: with ps; [
      # keep-sorted start
      ipykernel
      matplotlib
      numpy
      pandas
      scipy
      sympy
      # keep-sorted end
    ]
  );

  # octave here has no qt or fltk, so plots go through gnuplot, minus the
  # warning it prints about that, and become pngs through ghostscript.
  # readline's bracketed paste would put escape codes in every output
  inputrc = pkgs.writeText "inputrc" "set enable-bracketed-paste off\n";
  octave = pkgs.writeShellScriptBin "octave" ''
    export INPUTRC=${inputrc}
    export PATH=${
      lib.strings.makeBinPath [
        pkgs.ghostscript
        pkgs.gnuplot
      ]
    }:$PATH
    exec ${lib.meta.getExe pkgs.octave} --persist --eval "warning('off', 'Octave:gnuplot-graphics');" "$@"
  '';

  # jupyterlab's theme variables are on :root too and load after this, so
  # html:root wins without !important everywhere
  css = pkgs.writeText "custom.css" ''
    ${theme.import}
    html:root {
      --jp-ui-font-family: var(--font);
      --jp-layout-color0: var(--base00);
      --jp-layout-color1: var(--base00);
      --jp-layout-color2: var(--base01);
      --jp-layout-color3: var(--base02);
      --jp-layout-color4: var(--base03);
      --jp-border-color0: var(--base03);
      --jp-border-color1: var(--base02);
      --jp-border-color2: var(--base02);
      --jp-border-color3: var(--base01);
      --jp-ui-font-color0: var(--base07);
      --jp-ui-font-color1: var(--base05);
      --jp-ui-font-color2: var(--base04);
      --jp-ui-font-color3: var(--base03);
      --jp-content-font-color0: var(--base07);
      --jp-content-font-color1: var(--base05);
      --jp-content-font-color2: var(--base04);
      --jp-content-font-color3: var(--base03);
      --jp-content-link-color: var(--base0D);
      --jp-content-link-visited-color: var(--base0E);
      --jp-content-link-hover-color: var(--accent-hover);
      --jp-brand-color0: var(--base0D);
      --jp-brand-color1: var(--base0D);
      --jp-brand-color2: color-mix(in oklab, var(--base0D), var(--base00) 40%);
      --jp-brand-color3: color-mix(in oklab, var(--base0D), var(--base00) 70%);
      --jp-accent-color0: var(--base0C);
      --jp-accent-color1: var(--base0C);
      --jp-warn-color0: var(--base0A);
      --jp-warn-color1: var(--base0A);
      --jp-error-color0: var(--base08);
      --jp-error-color1: var(--base08);
      --jp-success-color0: var(--base0B);
      --jp-success-color1: var(--base0B);
      --jp-info-color0: var(--base0C);
      --jp-info-color1: var(--base0C);
      --jp-cell-editor-background: var(--base01);
      --jp-cell-editor-border-color: var(--base02);
      --jp-cell-editor-active-background: var(--base01);
      --jp-cell-editor-active-border-color: var(--base0D);
      --jp-cell-inprompt-font-color: var(--base0D);
      --jp-cell-outprompt-font-color: var(--base0E);
      --jp-notebook-select-background: var(--base02);
      --jp-notebook-multiselected-color: var(--accent-soft);
      --jp-rendermime-error-background: color-mix(in oklab, var(--base08) 15%, var(--base00));
      --jp-rendermime-table-row-background: var(--base01);
      --jp-rendermime-table-row-hover-background: var(--base02);
      --jp-dialog-background: color-mix(in oklab, var(--base00) 75%, transparent);
      --jp-toolbar-background: var(--base00);
      --jp-toolbar-border-color: var(--base02);
      --jp-toolbar-active-background: var(--base02);
      --jp-input-background: var(--base01);
      --jp-input-hover-background: var(--base02);
      --jp-input-active-background: var(--base01);
      --jp-input-border-color: var(--base02);
      --jp-input-active-border-color: var(--base0D);
      --jp-editor-selected-background: var(--base02);
      --jp-editor-selected-focused-background: var(--base02);
      --jp-editor-cursor-color: var(--base05);
      --jp-mirror-editor-keyword-color: var(--base0E);
      --jp-mirror-editor-atom-color: var(--base09);
      --jp-mirror-editor-number-color: var(--base09);
      --jp-mirror-editor-def-color: var(--base0D);
      --jp-mirror-editor-variable-color: var(--base05);
      --jp-mirror-editor-variable-2-color: var(--base08);
      --jp-mirror-editor-variable-3-color: var(--base0A);
      --jp-mirror-editor-punctuation-color: var(--base05);
      --jp-mirror-editor-property-color: var(--base0D);
      --jp-mirror-editor-operator-color: var(--base0C);
      --jp-mirror-editor-comment-color: var(--base03);
      --jp-mirror-editor-string-color: var(--base0B);
      --jp-mirror-editor-string-2-color: var(--base0B);
      --jp-mirror-editor-meta-color: var(--base0F);
      --jp-mirror-editor-qualifier-color: var(--base0A);
      --jp-mirror-editor-builtin-color: var(--base0C);
      --jp-mirror-editor-bracket-color: var(--base04);
      --jp-mirror-editor-tag-color: var(--base08);
      --jp-mirror-editor-attribute-color: var(--base0A);
      --jp-mirror-editor-header-color: var(--base0D);
      --jp-mirror-editor-quote-color: var(--base0B);
      --jp-mirror-editor-link-color: var(--base0D);
      --jp-mirror-editor-error-color: var(--base08);
      --jp-search-selected-match-background-color: var(--base0A);
      --jp-search-selected-match-color: var(--base00);
      --jp-search-unselected-match-background-color: var(--base02);
      --jp-search-unselected-match-color: var(--base05);
      --jp-scrollbar-background-color: var(--base00);
      --jp-scrollbar-thumb-color: var(--base03);
      --jp-focus-outline-color: var(--base0D);
      --jp-vega-background: var(--base00);
    }
  '';

  rgb = base: lib.strings.concatMapStringsSep ", " toString theme.rgb.${base};

  # the hub's login and control pages are bootstrap, with its dark mode
  # toggle hidden since the colors here hold either way
  hubTemplates = pkgs.writeTextDir "page.html" ''
    {% extends "templates/page.html" %}
    {% block stylesheet %}
    {{ super() }}
    <style>
    ${theme.import}
    html[data-bs-theme], html:root {
      color-scheme: ${if config.stylix.polarity == "light" then "light" else "dark"};
      --bs-font-sans-serif: var(--font);
      --bs-body-bg: var(--base00);
      --bs-body-bg-rgb: ${rgb "base00"};
      --bs-body-color: var(--base05);
      --bs-body-color-rgb: ${rgb "base05"};
      --bs-emphasis-color: var(--base07);
      --bs-secondary-color: var(--base04);
      --bs-secondary-bg: var(--base01);
      --bs-secondary-bg-rgb: ${rgb "base01"};
      --bs-tertiary-bg: var(--base01);
      --bs-tertiary-bg-rgb: ${rgb "base01"};
      --bs-border-color: var(--base02);
      --bs-link-color: var(--base0D);
      --bs-link-color-rgb: ${rgb "base0D"};
      --bs-link-hover-color: var(--accent-hover);
      --bs-danger: var(--base08);
    }
    .btn-jupyter, .btn-primary {
      --bs-btn-color: var(--base00);
      --bs-btn-bg: var(--base0D);
      --bs-btn-border-color: var(--base0D);
      --bs-btn-hover-color: var(--base00);
      --bs-btn-hover-bg: var(--accent-hover);
      --bs-btn-hover-border-color: var(--accent-hover);
      --bs-btn-active-color: var(--base00);
      --bs-btn-active-bg: var(--accent-hover);
      --bs-btn-active-border-color: var(--accent-hover);
    }
    #login-main .auth-form-header {
      color: var(--base00);
      background: var(--base0D);
    }
    .form-control:focus {
      border-color: var(--base0D);
      box-shadow: 0 0 0 0.25rem var(--accent-soft);
    }
    #dark-theme-toggle {
      display: none;
    }
    </style>
    {% endblock stylesheet %}
  '';

  # no jupyter news or update checks, nixpkgs does the updates. the built-in
  # theme sits under the colors above, for the icons and widgets the
  # variables don't reach
  settings = pkgs.writeTextDir "settings/overrides.json" (
    builtins.toJSON (
      {
        "@jupyterlab/apputils-extension:notification" = {
          fetchNews = "false";
          checkForUpdates = false;
        };
      }
      // lib.attrsets.optionalAttrs (theme != null) {
        "@jupyterlab/apputils-extension:themes".theme =
          if config.stylix.polarity == "light" then "JupyterLab Light" else "JupyterLab Dark";
      }
    )
  );

  # for each user's jupyterlab
  args = [
    "--MappingKernelManager.cull_idle_timeout=3600"
    "--MappingKernelManager.cull_interval=300"
    "--MappingKernelManager.cull_connected=True"
    "--ServerApp.shutdown_no_activity_timeout=7200"
    "--LabApp.app_settings_dir=${settings}/settings"
  ]
  ++ lib.lists.optional (theme != null) "--LabApp.custom_css=True";
in

{
  options.dotnix.services.compute.enable =
    lib.options.mkEnableOption "jupyterhub with python, sagemath and octave, at compute.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.jupyterhub = {
      enable = true;
      host = "127.0.0.1";
      inherit port;

      kernels = {
        python3 = {
          displayName = "Python 3";
          argv = [
            python.interpreter
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          language = "python";
          logo32 = "${python}/${python.sitePackages}/ipykernel/resources/logo-32x32.png";
          logo64 = "${python}/${python.sitePackages}/ipykernel/resources/logo-64x64.png";
        };
        sagemath = pkgs.sage.kernelspec;
        octave = pkgs.octave-kernel.definition // {
          env.OCTAVE_EXECUTABLE = lib.meta.getExe octave;
        };
      };

      # glance has the hub's default port. only you get in; the login is
      # pam, so it is your login password
      extraConfig = ''
        c.JupyterHub.hub_bind_url = "http://127.0.0.1:${toString hubPort}"
        c.ConfigurableHTTPProxy.api_url = "http://127.0.0.1:${toString proxyApiPort}"
        c.Authenticator.allowed_users = {"${user}"}
        c.Spawner.notebook_dir = "${notebooks}"
        c.Spawner.args = ${builtins.toJSON args}
      ''
      + lib.strings.optionalString (theme != null) ''
        c.JupyterHub.template_paths = ["${hubTemplates}"]
      '';
    };

    # jupyter only looks for custom.css in ~/.jupyter/custom
    systemd.tmpfiles.rules =
      lib.lists.optional files.enable "d ${notebooks} 0750 ${user} users -"
      ++ lib.lists.optionals (theme != null) [
        "d ${home}/.jupyter 0700 ${user} users -"
        "d ${home}/.jupyter/custom 0700 ${user} users -"
        "L+ ${home}/.jupyter/custom/custom.css - - - - ${css}"
      ];

    dotnix.home.sites.compute = { inherit port; };
  };
}
