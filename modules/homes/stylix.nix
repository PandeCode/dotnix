# This file is for defining targets
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.stylix_home;
  dis = lib.mkIf config.stylix_home.dis.enable true;
in {
  options.stylix_home = {
    enable = lib.mkEnableOption "enable stylix in home-manager";
    dis.enable = lib.mkEnableOption "enable display (wallpapers, window manager)";
  };

  /*
  https://github.com/danth/stylix/blob/master/docs/src/styling.md

  */

  config = lib.mkIf cfg.enable {
    xdg.configFile."gowall/config.yml".text =
      lib.strings.toJSON
      {
        themes = [
          {
            name = "nix";
            colors = with config.lib.stylix.colors; map (s: "#" + s) [base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F];
          }
        ];
      };
    stylix =
      (import ../stylix/common.nix {inherit pkgs;}).stylix
      // {
        targets = {
          alacritty.enable = true;
          bat.enable = true;
          btop.enable = true;
          cava.enable = true;
          cava.rainbow.enable = true;
          dunst.enable = true;
          firefox.enable = true;
          fish.enable = true;
          fzf.enable = true;
          gtk.enable = true;
          gtk.flatpakSupport.enable = true;
          hyprland.enable = true;
          hyprland.hyprpaper.enable = false;
          hyprlock.enable = true;
          hyprpaper.enable = false;
          kitty.enable = true;
          lazygit.enable = true;
          ncspot.enable = true;
          neovim.enable = lib.mkForce false;
          rofi.enable = false;
          spicetify.enable = true;
          sway.enable = true;
          swaync.enable = true;
          vesktop.enable = true;
          waybar.enable = false;
          wezterm.enable = false;
          wob.enable = true;
          wofi.enable = true;
          wpaperd.enable = true;
          xresources.enable = true;
          zellij.enable = true;

          # avizo.enable = true;
          # bemenu.alternate
          # bemenu.enable = true;
          # bemenu.fontSize
          # bspwm.enable = true;
          # emacs.enable = true;
          # fcitx5.enable = true;
          # firefox.firefoxGnomeTheme.enable = true;
          # firefox.profileNames
          # foot.enable = true;
          # forge.enable = true;
          # fuzzel.enable = true;
          # gedit.enable = true;
          # ghostty.enable = true;
          # gitui.enable = true;
          # gnome-text-editor.enable = true;
          # gnome.enable = true;
          # gtk.extraCss
          # helix.enable = true;
          # i3.enable = true;
          # k9s.enable = true;
          # kde.enable = true;
          # kitty.variant256Colors
          # kubecolor.enable = true;
          # librewolf.enable = true;
          # librewolf.firefoxGnomeTheme.enable = true;
          # librewolf.profileNames
          # mako.enable = true;
          # mangohud.enable = true;
          # micro.enable = true;
          # neovim.plugin
          # neovim.transparentBackground.main
          # neovim.transparentBackground.signColumn
          # nixvim.enable = true;
          # nixvim.plugin
          # nixvim.transparentBackground.main
          # nixvim.transparentBackground.signColumn
          # nushell.enable = true;
          # qutebrowser.enable = true;
          # river.enable = true;
          # swaylock.enable = true;
          # swaylock.useImage
          # sxiv.enable = true;
          # tmux.enable = true;
          # tofi.enable = true;
          # vim.enable = true;
          # vscode.enable = true;
          # xfce.enable = true;
          # yazi.enable = true;
          # zathura.enable = true;
          # zed.enable = true;
        };
      };
  };
}
