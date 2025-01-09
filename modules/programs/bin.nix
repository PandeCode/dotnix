{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.bin;
in {
  options.bin.enable = lib.mkEnableOption "enable bin";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "fr" ''${builtins.readFile ../../bin/fr}'')
      (writeShellScriptBin "fman" ''
         #!/usr/bin/env bash
        MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"
           man -k . | fzf -q "$1" --prompt='man> '  --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
      '')
    ];
  };
}
