# nix.<domain>: a search of every dotnix.* option, built from this
# machine's own options, and every nixbuilds package
{
  config,
  inputs,
  lib,
  options,
  pkgs,
  self,
  ...
}:

{
  options.dotnix.services.nix.enable =
    lib.options.mkEnableOption "a search of dotnix options and nixbuilds packages, at nix.<domain>";

  config = lib.modules.mkIf config.dotnix.services.nix.enable {
    dotnix.home.sites.nix.root =
      let
        site = pkgs.callPackage "${self}/docs/search" {
          inherit inputs options self;
        };
        inherit (config.dotnix.home) theme;
        # its colors are compiled in; the font is not
        style = "<style>${theme.import} body { font-family: var(--font); }</style>";
      in
      if theme == null then
        site
      else
        pkgs.runCommand "nix-search" { } ''
          cp -r ${site} $out
          chmod -R u+w $out
          substituteInPlace $out/index.html --replace-fail "</head>" ${lib.strings.escapeShellArg "${style}</head>"}
        '';
  };
}
