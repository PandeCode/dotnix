# draw.<domain>: excalidraw, from nixbuilds, a whiteboard for sketches and
# diagrams. just files caddy serves; drawings stay in your browser until you
# save them as .excalidraw files
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.home) theme;

  # its dark mode, in theme colors. the drawing itself is inverted by
  # excalidraw, so only the panels and menus follow the theme
  overrides = pkgs.writeText "draw-theme.css" ''
    ${theme.import}
    .excalidraw.theme--dark {
      --default-bg-color: var(--base00);
      --island-bg-color: var(--base01);
      --island-bg-color-alt: var(--base00);
      --input-bg-color: var(--base00);
      --input-border-color: var(--base02);
      --input-hover-bg-color: var(--base01);
      --popup-secondary-bg-color: var(--base01);
      --popup-text-color: var(--base05);
      --keybinding-color: var(--base04);
      --button-gray-1: var(--base02);
      --button-gray-2: var(--base01);
      --button-gray-3: var(--base01);
      --scrollbar-thumb: var(--base03);
      --scrollbar-thumb-hover: var(--base04);
      --color-surface-lowest: var(--base00);
      --color-surface-low: var(--base01);
      --color-surface-mid: var(--base01);
      --color-surface-high: var(--base02);
      --color-on-surface: var(--base05);
      --color-border-outline: var(--base04);
      --color-border-outline-variant: var(--base02);
      --color-logo-text: var(--base06);
      --color-primary: var(--base0D);
      --color-primary-darker: color-mix(in oklab, var(--base0D), var(--base07) 10%);
      --color-primary-darkest: color-mix(in oklab, var(--base0D), var(--base07) 20%);
      --color-primary-hover: color-mix(in oklab, var(--base0D), var(--base07) 20%);
      --color-primary-light: color-mix(in oklab, var(--base0D), var(--base00) 60%);
      --color-primary-light-darker: color-mix(in oklab, var(--base0D), var(--base00) 70%);
      --color-brand-hover: color-mix(in oklab, var(--base0D), var(--base07) 20%);
      --color-brand-active: color-mix(in oklab, var(--base0D), var(--base07) 30%);
      --color-surface-primary-container: color-mix(in oklab, var(--base0D), var(--base00) 60%);
      --color-on-primary-container: var(--base07);
      --color-selection: var(--base0D);
      --select-highlight-color: var(--base0D);
      --focus-highlight-color: var(--base0D);
      --link-color: var(--base0D);
      --color-danger: var(--base08);
    }
    html.dark {
      background-color: var(--base00);
    }
    /* the excalidraw+ trial ad */
    .plus-banner {
      display: none;
    }
  '';

  # the same files, with the stylesheet added to the page
  site = pkgs.runCommand "excalidraw-themed" { nativeBuildInputs = [ pkgs.lndir ]; } ''
    mkdir $out
    lndir -silent ${pkgs.excalidraw} $out
    cp ${overrides} $out/dotnix-theme.css
    rm $out/index.html
    sed 's|</head>|<link rel="stylesheet" href="/dotnix-theme.css"></head>|' \
      ${pkgs.excalidraw}/index.html >$out/index.html
  '';
in

{
  options.dotnix.services.draw.enable = lib.options.mkEnableOption "excalidraw, at draw.<domain>";

  config = lib.modules.mkIf config.dotnix.services.draw.enable {
    dotnix.home.sites.draw.root = if theme != null then site else pkgs.excalidraw;
  };
}
