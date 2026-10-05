# pdf.<domain>: bentopdf, merge, split, compress, sign and convert pdfs.
# just files caddy serves; the work happens in your browser, so nothing is
# uploaded
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.home) theme;

  # its colors are tailwind scales, 50 light to 950 dark, each around one
  # theme color
  shades = {
    "50" = "var(--base07) 85%";
    "100" = "var(--base07) 70%";
    "200" = "var(--base07) 50%";
    "300" = "var(--base07) 30%";
    "400" = "var(--base07) 15%";
    "600" = "var(--base00) 15%";
    "700" = "var(--base00) 30%";
    "800" = "var(--base00) 50%";
    "900" = "var(--base00) 70%";
    "950" = "var(--base00) 85%";
  };
  scale =
    name: base:
    lib.strings.concatLines (
      [ "  --color-${name}-500: var(--${base});" ]
      ++ lib.attrsets.mapAttrsToList (
        step: mix: "  --color-${name}-${step}: color-mix(in oklab, var(--${base}), ${mix});"
      ) shades
    );
  hues = {
    amber = "base09";
    blue = "base0D";
    green = "base0B";
    indigo = "base0D";
    orange = "base09";
    pink = "base08";
    purple = "base0E";
    red = "base08";
    rose = "base08";
    teal = "base0C";
    violet = "base0E";
    yellow = "base0A";
  };
  grays = ''
    --color-gray-50: var(--base07);
    --color-gray-100: var(--base07);
    --color-gray-200: var(--base06);
    --color-gray-300: var(--base05);
    --color-gray-400: color-mix(in oklab, var(--base04), var(--base05));
    --color-gray-500: var(--base04);
    --color-gray-600: var(--base03);
    --color-gray-700: var(--base02);
    --color-gray-800: var(--base01);
    --color-gray-900: var(--base00);
    --color-gray-950: color-mix(in oklab, var(--base00), black 20%);
  '';

  # its own parts still name the old tailwind colors outright
  literals = {
    "#111827" = "gray-900";
    "#1f2937" = "gray-800";
    "#374151" = "gray-700";
    "#4b5563" = "gray-600";
    "#6b7280" = "gray-500";
    "#9ca3af" = "gray-400";
    "#d1d5db" = "gray-300";
    "#e5e7eb" = "gray-200";
    "#a5b4fc" = "indigo-300";
    "#818cf8" = "indigo-400";
    "#6366f1" = "indigo-500";
    "#4f46e5" = "indigo-600";
    "#4338ca" = "indigo-700";
    "#8b5cf6" = "violet-500";
  };
  recolor = lib.strings.concatStrings (
    lib.attrsets.mapAttrsToList (hex: color: " -e 's/${hex}/var(--color-${color})/gI'") literals
  );

  overrides = pkgs.writeText "pdf-theme.css" ''
    /* above its own colors, which it keeps in a layer */
    :root {
    ${grays}
    ${lib.strings.concatStrings (lib.attrsets.mapAttrsToList scale hues)}
      --color-slate-500: var(--base04);
      --color-white: var(--base07);
      --color-black: var(--base00);
      --font-sans: var(--font);
    }
    body {
      font-family: var(--font);
    }
  '';

  # the same files, with the theme added to the stylesheet every page loads
  site = pkgs.runCommand "bentopdf-themed" { nativeBuildInputs = [ pkgs.lndir ]; } ''
    mkdir $out
    lndir -silent ${pkgs.bentopdf} $out
    for css in $out/assets/style-*.css; do
      rm -f "$css" "$css.br"
      {
        echo '${theme.import}'
        sed${recolor} ${pkgs.bentopdf}/assets/"''${css##*/}"
        cat ${overrides}
      } >"$css"
    done
  '';
in

{
  options.dotnix.services.pdf.enable = lib.options.mkEnableOption "bentopdf, at pdf.<domain>";

  config = lib.modules.mkIf config.dotnix.services.pdf.enable {
    dotnix.home.sites.pdf.root = if theme != null then site else pkgs.bentopdf;
  };
}
