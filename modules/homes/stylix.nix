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
  base00 - Default Background
  base01 - Lighter Background (Used for status bars, line number and folding marks)
  base02 - Selection Background
  base03 - Comments, Invisibles, Line Highlighting
  base04 - Dark Foreground (Used for status bars)
  base05 - Default Foreground, Caret, Delimiters, Operators
  base06 - Light Foreground (Not often used)
  base07 - Light Background (Not often used)
  base08 - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A - Classes, Markup Bold, Search Text Background
  base0B - Strings, Inherited Class, Markup Code, Diff Inserted
  base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D - Functions, Methods, Attribute IDs, Headings
  base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F - Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
  */

  config = lib.mkIf cfg.enable {
    stylix =
      (import ../stylix/common.nix {inherit pkgs;}).stylix
      // {
        targets = {
          alacritty.enable = true;
          # avizo.enable = true;
          bat.enable = true;
          # bemenu.enable = true;
          # bemenu.alternate
          # bemenu.fontSize
          # bspwm.enable = true;
          btop.enable = true;
          cava.enable = true;
          cava.rainbow.enable = true;
          dunst.enable = true;
          # emacs.enable = true;
          # fcitx5.enable = true;
          # firefox.enable = true;
          # firefox.firefoxGnomeTheme.enable = true;
          # firefox.profileNames
          fish.enable = true;
          # foot.enable = true;
          # forge.enable = true;
          # fuzzel.enable = true;
          fzf.enable = true;
          # gedit.enable = true;
          # ghostty.enable = true;
          # gitui.enable = true;
          # gnome.enable = true;
          # gnome-text-editor.enable = true;
          gtk.enable = true;
          # gtk.extraCss
          gtk.flatpakSupport.enable = true;
          # helix.enable = true;
          hyprland.enable = dis;
          hyprland.hyprpaper.enable = dis;
          hyprlock.enable = dis;
          hyprpaper.enable = dis;
          # i3.enable = true;
          # k9s.enable = true;
          # kde.enable = true;
          kitty.enable = true;
          # kitty.variant256Colors
          # kubecolor.enable = true;
          lazygit.enable = true;
          # librewolf.enable = true;
          # librewolf.firefoxGnomeTheme.enable = true;
          # librewolf.profileNames
          # mako.enable = true;
          # mangohud.enable = true;
          # micro.enable = true;
          ncspot.enable = true;
          neovim.enable = lib.mkForce false; # WARN: I already handle this
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
          rofi.enable = true;
          spicetify.enable = true;
          # sway.enable = true;
          # swaylock.enable = true;
          # swaylock.useImage
          # swaync.enable = true;
          # sxiv.enable = true;
          # tmux.enable = true;
          # tofi.enable = true;
          vesktop.enable = true;
          # vim.enable = true;
          # vscode.enable = true;
          waybar.enable = false;
          # waybar.enable = true; CenterBackColors
          # waybar.enable = true; LeftBackColors
          # waybar.enable = true; RightBackColors
          wezterm.enable = false;
          wob.enable = true;
          wofi.enable = true;
          wpaperd.enable = true;
          # xfce.enable = true;
          xresources.enable = true;
          # yazi.enable = true;
          # zathura.enable = true;
          # zed.enable = true;
          zellij.enable = true;
        };
      };
  };
}
