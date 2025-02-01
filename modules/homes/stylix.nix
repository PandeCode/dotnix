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

  Rosewater #f5e0dc	 rgb(245, 224, 220)	 hsl(10deg, 56%, 91%)
  Flamingo #f2cdcd 	 rgb(242, 205, 205)	 hsl(0deg, 59%, 88%)
  Pink #f5c2e7     	 rgb(245, 194, 231)	 hsl(316deg, 72%, 86%)
  Mauve #cba6f7    	 rgb(203, 166, 247)	 hsl(267deg, 84%, 81%)
  Red #f38ba8      	 rgb(243, 139, 168)	 hsl(343deg, 81%, 75%)
  Maroon #eba0ac   	 rgb(235, 160, 172)	 hsl(350deg, 65%, 77%)
  Peach #fab387    	 rgb(250, 179, 135)	 hsl(23deg, 92%, 75%)
  Yellow #f9e2af   	 rgb(249, 226, 175)	 hsl(41deg, 86%, 83%)
  Green #a6e3a1    	 rgb(166, 227, 161)	 hsl(115deg, 54%, 76%)
  Teal #94e2d5     	 rgb(148, 226, 213)	 hsl(170deg, 57%, 73%)
  Sky #89dceb      	 rgb(137, 220, 235)	 hsl(189deg, 71%, 73%)
  Sapphire #74c7ec 	 rgb(116, 199, 236)	 hsl(199deg, 76%, 69%)
  Blue #89b4fa     	 rgb(137, 180, 250)	 hsl(217deg, 92%, 76%)
  Lavender #b4befe 	 rgb(180, 190, 254)	 hsl(232deg, 97%, 85%)
  Text #cdd6f4     	 rgb(205, 214, 244)	 hsl(226deg, 64%, 88%)
  Subtext 1 #bac2de	 rgb(186, 194, 222)	 hsl(227deg, 35%, 80%)
  Subtext 0 #a6adc8	 rgb(166, 173, 200)	 hsl(228deg, 24%, 72%)
  Overlay 2 #9399b2	 rgb(147, 153, 178)	 hsl(228deg, 17%, 64%)
  Overlay 1 #7f849c	 rgb(127, 132, 156)	 hsl(230deg, 13%, 55%)
  Overlay 0 #6c7086	 rgb(108, 112, 134)	 hsl(231deg, 11%, 47%)
  Surface 2 #585b70	 rgb(88, 91, 112)  	 hsl(233deg, 12%, 39%)
  Surface 1 #45475a	 rgb(69, 71, 90)   	 hsl(234deg, 13%, 31%)
  Surface 0 #313244	 rgb(49, 50, 68)   	 hsl(237deg, 16%, 23%)
  Base #1e1e2e     	 rgb(30, 30, 46)   	 hsl(240deg, 21%, 15%)
  Mantle #181825   	 rgb(24, 24, 37)   	 hsl(240deg, 21%, 12%)
  Crust #11111b    	 rgb(17, 17, 27)   	 hsl(240deg, 23%, 9%)
  */

  config = lib.mkIf cfg.enable {
    home.file.".config/gowall/config.yml".text =
      # this is catppuccin-mocha
      #yaml
      ''
        themes:
              - name: "nix"
                colors:
                  - "#F5E0DC"
                  - "#F2CDCD"
                  - "#F5C2E7"
                  - "#CBA6F7"
                  - "#F38BA8"
                  - "#EBA0AC"
                  - "#FAB387"
                  - "#F9E2AF"
                  - "#A6E3A1"
                  - "#94E2D5"
                  - "#89DCEB"
                  - "#74C7EC"
                  - "#89B4FA"
                  - "#B4BEFE"
                  - "#CDD6F4"
                  - "#BAC2DE"
                  - "#A6ADC8"
                  - "#9399B2"
                  - "#7F849C"
                  - "#6C7086"
                  - "#585B70"
                  - "#45475A"
                  - "#313244"
                  - "#1E1E2E"
                  - "#181825"
                  - "#11111B"
      '';
    stylix =
      (import ../stylix/common.nix {inherit pkgs;}).stylix
      // {
        targets = {
          # I handle
          waybar.enable = false;
          wezterm.enable = false;
          rofi.enable = false;
          hyprland.hyprpaper.enable = false;
          hyprpaper.enable = false;

          zellij.enable = true;

          kitty.enable = true;
          # kitty.variant256Colors

          alacritty.enable = true;
          bat.enable = true;
          btop.enable = true;
          cava.enable = true;
          cava.rainbow.enable = true;
          dunst.enable = true;
          fish.enable = true;
          fzf.enable = true;
          firefox.enable = true;

          hyprland.enable = true;
          hyprlock.enable = true;

          gtk.enable = true;
          gtk.flatpakSupport.enable = true;
          # gtk.extraCss

          # avizo.enable = true;
          # bemenu.enable = true;
          # bemenu.alternate
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
          # gnome.enable = true;
          # gnome-text-editor.enable = true;
          # helix.enable = true;
          # i3.enable = true;
          # k9s.enable = true;
          # kde.enable = true;
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
          spicetify.enable = true;
          sway.enable = true;
          # swaylock.enable = true;
          # swaylock.useImage
          swaync.enable = true;
          # sxiv.enable = true;
          # tmux.enable = true;
          # tofi.enable = true;
          vesktop.enable = true;
          # vim.enable = true;
          # vscode.enable = true;
          wob.enable = true;
          wofi.enable = true;
          wpaperd.enable = true;
          # xfce.enable = true;
          xresources.enable = true;
          # yazi.enable = true;
          # zathura.enable = true;
          # zed.enable = true;
        };
      };
  };
}
