# theme.<domain>: the stylix colors and fonts as one stylesheet, for the web
# apps to import. sixteen colors are too few for a web ui, so it adds the
# palette's roles (surface, border, accent, ...) and a ramp of shades from
# base00 to base07
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix) home;

  enable = home.enable && config.stylix.enable;

  colors = config.lib.stylix.colors.withHashtag;
  inherit (config.stylix.fonts.sansSerif) name;
  mono = config.stylix.fonts.monospace.name;
  inherit (config.dotnix.profiles.theme) palette webFont webMonoFont;

  bases = map (n: "base0${n}") [
    "0"
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "A"
    "B"
    "C"
    "D"
    "E"
    "F"
  ];

  rgb =
    base:
    map (channel: lib.strings.toInt config.lib.stylix.colors."${base}-rgb-${channel}") [
      "r"
      "g"
      "b"
    ];

  # "h s% l%", the form shadcn-style apps keep their colors in
  hsl =
    base:
    let
      r = builtins.elemAt (rgb base) 0 / 255.0;
      g = builtins.elemAt (rgb base) 1 / 255.0;
      b = builtins.elemAt (rgb base) 2 / 255.0;
      max = lib.lists.foldl' lib.trivial.max r [
        g
        b
      ];
      min = lib.lists.foldl' lib.trivial.min r [
        g
        b
      ];
      d = max - min;
      l = (max + min) / 2;
      s = if d == 0 then 0.0 else d / (1 - (if 2 * l - 1 < 0 then 1 - 2 * l else 2 * l - 1));
      h0 =
        if d == 0 then
          0.0
        else if max == r then
          (g - b) / d + (if g < b then 6 else 0)
        else if max == g then
          (b - r) / d + 2
        else
          (r - g) / d + 4;
      round = x: toString (builtins.floor (x + 0.5));
    in
    "${round (h0 * 60)} ${round (s * 100)}% ${round (l * 100)}%";

  # base00 to base07 with a step mixed between each pair
  ramp =
    lib.lists.imap0 (
      i: _:
      let
        lo = builtins.elemAt bases (i / 2);
        hi = builtins.elemAt bases (i / 2 + 1);
      in
      if lib.trivial.mod i 2 == 0 then
        "var(--${lo})"
      else
        "color-mix(in oklab, var(--${lo}), var(--${hi}))"
    ) (lib.lists.range 0 13)
    ++ [ "var(--base07)" ];

  face = family: file: format: ''
    @font-face {
      font-family: "${family}";
      src: local("${family}"), url("${file}") format("${format}");
      font-display: swap;
    }
  '';

  css = ''
    ${lib.strings.optionalString (webFont != null) (face name "font.otf" "opentype")}
    ${lib.strings.optionalString (webMonoFont != null) (face mono "font-mono.ttf" "truetype")}
    :root {
    ${lib.strings.concatMapStrings (b: "  --${b}: ${colors.${b}};\n") bases}
    ${lib.strings.concatStrings (lib.lists.imap0 (i: v: "  --ramp-${toString i}: ${v};\n") ramp)}
    ${lib.strings.concatStrings (
      lib.attrsets.mapAttrsToList (role: color: "  --${role}: ${color};\n") palette
    )}
      --overlay: var(--raised);
      --accent-hover: color-mix(in oklab, var(--accent), var(--bright) 20%);
      --accent-soft: color-mix(in oklab, var(--accent) 20%, transparent);
      --font: "${name}", sans-serif;
      --mono: "${mono}", monospace;
    }

    /* links in running text point up and out; app links with their own
       class are left alone */
    p a:not([class])::after,
    li a:not([class])::after {
      content: "\2197";
      font-size: 0.8em;
      margin-left: 1px;
    }
  '';

  root = pkgs.runCommand "dotnix-theme" { } ''
    mkdir $out
    cp ${pkgs.writeText "theme.css" css} $out/theme.css
    ${lib.strings.optionalString (webFont != null) "cp ${webFont} $out/font.otf"}
    ${lib.strings.optionalString (webMonoFont != null) "cp ${webMonoFont} $out/font-mono.ttf"}
  '';
in

{
  options.dotnix.home.theme = lib.options.mkOption {
    type = lib.types.nullOr lib.types.raw;
    readOnly = true;
    default =
      if enable then
        {
          inherit colors root;
          rgb = lib.attrsets.genAttrs bases rgb;
          hsl = lib.attrsets.genAttrs bases hsl;
          font = name;
          inherit mono palette;
          url = "https://theme.${home.domain}/theme.css";
          import = ''@import url("https://theme.${home.domain}/theme.css");'';
        }
      else
        null;
    description = ''
      The stylix theme for web apps, or null without stylix: colors as hex,
      rgb and hsl, the palette's roles, the font and code font names, the
      stylesheet's url with css to import it, and its folder for apps that
      only load styles from themselves.
    '';
  };

  config = lib.modules.mkIf enable {
    dotnix.home.sites.theme = {
      inherit root;
      listed = false;
      # fonts load across sites only when allowed, and caddy would call
      # an .otf an office template
      extraConfig = ''
        header Access-Control-Allow-Origin *
        header /font.otf Content-Type font/otf
        header /font-mono.ttf Content-Type font/ttf
      '';
    };
  };
}
