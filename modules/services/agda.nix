# agda.<domain>: let's play agda, agda exercises with emacs in the browser.
# upstream's own nixos container: nginx for the pages and ttyd giving each
# exercise an emacs in a bubblewrap sandbox with no network. emacs can run
# shell commands, so the page is a (sandboxed) shell and stays behind the
# password
{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.dotnix.services.agda;
  src = inputs.lets-play-agda;

  # upstream takes its font cache with builtins.fetchTarball, which lix
  # refuses for a tarball of loose files. the same files through fetchzip,
  # by rewriting the two files that lead there. a rewrite that no longer
  # matches stops the build instead of quietly doing nothing
  rewrite =
    name: from: to:
    let
      text = builtins.readFile "${src}/nix/${name}";
    in
    assert lib.asserts.assertMsg (lib.lists.all (
      old: lib.strings.hasInfix old text
    ) from) "lets-play-agda: nix/${name} changed upstream";
    builtins.toFile name (builtins.replaceStrings from to text);

  frontend =
    rewrite "frontend-package.nix"
      [
        "{ lib,"
        "src = ./..;"
        "builtins.fetchTarball {"
        "sha256 = \"sha256:099shj6p6i96p9l43b15z36ghhiq45pq6i33bbhyh39pfiyxfk56\";"
      ]
      [
        "{ fetchzip, lib,"
        "src = ${src};"
        "fetchzip { stripRoot = false;"
        "hash = \"sha256-pkzXfXQ3DejhWmNEg28hOEL4zPglrEFouiZFc42EOiU=\";"
      ];

  container =
    rewrite "container.nix"
      [
        "./frontend-package.nix"
        "./backend-package.nix"
      ]
      [
        "${frontend}"
        "${src}/nix/backend-package.nix"
      ];

  # a /30 of its own, clear of the lan, tailscale and docker
  hostAddress = "10.233.1.1";
  localAddress = "10.233.1.2";
in

{
  options.dotnix.services.agda.enable =
    lib.options.mkEnableOption "let's play agda, agda exercises in the browser at agda.<domain>";

  config = lib.modules.mkIf cfg.enable {
    containers.agda = {
      # nothing to keep: every start is a fresh root
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      inherit hostAddress localAddress;
      config = {
        imports = [ (import container { commit-id = src.rev; }) ];
        system.stateVersion = "26.05";
      };
    };

    # every open exercise is an agda and an emacs; enough for a few at once,
    # and a runaway proof can't starve the rest of the server
    systemd.services."container@agda".serviceConfig = {
      MemoryMax = "4G";
      CPUQuota = "200%";
      TasksMax = 512;
    };

    dotnix.home.sites.agda = {
      upstream = "${localAddress}:80";
      protect = true;
    };
  };
}
