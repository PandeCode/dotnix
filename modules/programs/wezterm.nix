{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wezterm;
in {
  programs.wezterm = {
    enable = true;

    extraConfig =
      /*
      lua
      */
      ''
          local wezterm = require "wezterm"
          local config = wezterm.config_builder()


        ${builtins.readFile ../../config/wezterm/utils.lua}
        ${builtins.readFile ../../config/wezterm/overrides.lua}

        ${builtins.readFile ../../config/wezterm/wezterm.lua}

        config.keys = ( function() ${builtins.readFile ../../config/wezterm/keys.lua} end )()
        config.mouse_bindings = ( function() ${builtins.readFile ../../config/wezterm/mouse.lua} end )()

        return config
      '';
  };
}
