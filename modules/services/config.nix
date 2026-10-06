# config.<domain>: every machine's dotnix settings as they evaluate, system
# and home, as a page to browse. it is made with this machine's build, so it
# shows what the flake says, as of the last switch
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix.home) theme;

  cfg = config.dotnix.services.config;

  # this page itself, which would otherwise read itself while being made
  skip = [
    [
      "home"
      "sites"
      "config"
    ]
    [
      "services"
      "config"
      "hosts"
    ]
  ];

  # plain json: packages by name, functions marked, and options nothing set
  # marked as unset instead of failing the whole page
  dump =
    path: value:
    let
      r = builtins.tryEval value;
      v = r.value;
    in
    if lib.lists.elem path skip then
      "<this page>"
    else if !r.success then
      { "<unset>" = true; }
    else if lib.attrsets.isDerivation v then
      "<package ${v.name or "?"}>"
    else if builtins.isFunction v then
      "<function>"
    else if builtins.isAttrs v then
      lib.attrsets.mapAttrs (name: dump (path ++ [ name ])) v
    else if builtins.isList v then
      lib.lists.imap0 (i: dump (path ++ [ (toString i) ])) v
    else if builtins.isPath v then
      toString v
    else if builtins.isString v then
      builtins.unsafeDiscardStringContext v
    else
      v;

  data = lib.attrsets.mapAttrs (
    _: host:
    {
      system = dump [ ] host.config.dotnix;
    }
    // lib.attrsets.mapAttrs' (user: home: {
      name = "home ${user}";
      value = dump [ ] (home.dotnix or { });
    }) (host.config.home-manager.users or { })
  ) cfg.hosts;

  site = pkgs.runCommand "dotnix-config" { } ''
    mkdir $out
    cp ${pkgs.writeText "data.json" (builtins.toJSON data)} $out/data.json
    cp ${./config.html} $out/index.html
    ${lib.strings.optionalString (theme != null) ''
      substituteInPlace $out/index.html --replace-fail "<!-- theme -->" \
        ${lib.strings.escapeShellArg "<style>${theme.import}</style>"}
    ''}
  '';
in

{
  options.dotnix.services.config = {
    enable = mkEnableOption "a page of every machine's dotnix settings, at config.<domain>";

    hosts = mkOption {
      type = types.attrsOf types.raw;
      default.${config.networking.hostName} = { inherit config; };
      defaultText = lib.literalMD "this machine";
      description = ''
        The machines to show, as nixosConfigurations. Each is evaluated as
        part of this machine's build.
      '';
    };
  };

  config = lib.modules.mkIf cfg.enable {
    # it shows the private repo's settings too
    dotnix.home.sites.config = {
      root = site;
      protect = true;
    };
  };
}
