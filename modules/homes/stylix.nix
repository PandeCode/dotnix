{
  pkgs,
  lib,
  config,
  ...
} @ all: {
  # TODO: enable when needed
  specialisation = {
    dark.configuration = {
      stylix.base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      home = {
        sessionVariables.THEME = "dark";
        activation.setTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
        '';
      };
    };

    light.configuration = {
      stylix.base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tokyo-night-light.yaml";
      home = {
        sessionVariables.THEME = "light";
        activation.setTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
        '';
      };
    };
  };

  xdg.configFile = {
    "gowall/config.yml".text =
      lib.strings.toJSON
      {
        EnableImagePreviewing = false;
        themes = [
          {
            name = "nix";
            colors = with config.lib.stylix.colors; map (s: "#" + s) [base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F];
          }
        ];
      };

    "stylix/style.scss".text = with config.lib.stylix.colors;
    /*
    scss
    */
      ''
        $base00: #${base00}; $base01: #${base01}; $base02: #${base02}; $base03: #${base03};
        $base04: #${base04}; $base05: #${base05}; $base06: #${base06}; $base07: #${base07};
        $base08: #${base08}; $base09: #${base09}; $base0A: #${base0A}; $base0B: #${base0B};
        $base0C: #${base0C}; $base0D: #${base0D}; $base0E: #${base0E}; $base0F: #${base0F};
      '';
    "stylix/style.lua".text = with config.lib.stylix.colors;
    /*
    lua
    */
      ''
        return {
          base00 = '#${base00}', base01 = '#${base01}', base02 = '#${base02}', base03 = '#${base03}',
          base04 = '#${base04}', base05 = '#${base05}', base06 = '#${base06}', base07 = '#${base07}',
          base08 = '#${base08}', base09 = '#${base09}', base0A = '#${base0A}', base0B = '#${base0B}',
          base0C = '#${base0C}', base0D = '#${base0D}', base0E = '#${base0E}', base0F = '#${base0F}'
        }
      '';
  };

  home = {
    sessionVariables = {
      XCURSOR_THEME = config.home.pointerCursor.name;
      XCURSOR_SIZE = config.home.pointerCursor.size;
    };
    home.activation.setTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    '';
    packages = [pkgs.bibata-cursors];
    # pointerCursor = {
    #   gtk.enable = true;
    #   x11.enable = true;
    #   size = 48;
    #   package = pkgs.bibata-cursors;
    #   name = "Bibata-Mordern-Ice";
    # };
  };

  stylix =
    (import ../stylix/common.nix all).stylix
    // {
      iconTheme = {
        enable = true;
        package = pkgs.arc-icon-theme;
        dark = "Arc-Dark";
        light = "Arc";
      };

      targets = {
        rofi.enable = false;
        hyprpaper.enable = false;
        hyprland.hyprpaper.enable = false;
        neovim.enable = lib.mkForce false;
        waybar.enable = false;
        wezterm.enable = true;
        hyprlock.enable = false;

        # neovim  = {
        #     plugin = "mini.base16";
        #     transparentBackground = {
        #         main = true;
        #         signColumn = true;
        #     };
        # };

        # alacritty.enable = true;
        # bat.enable = true;
        # btop.enable = true;
        # cava.enable = true;
        # cava.rainbow.enable = true;
        # dunst.enable = true;
        # firefox.enable = true;
        # fish.enable = true;
        # fzf.enable = true;
        # gtk.enable = true;
        # gtk.flatpakSupport.enable = true;
        # hyprland.enable = true;
        # kitty.enable = true;
        # lazygit.enable = true;
        # ncspot.enable = true;
        # spicetify.enable = true;
        # sway.enable = true;
        # swaync.enable = true;
        # vesktop.enable = true;
        # wob.enable = true;
        # wofi.enable = true;
        # wpaperd.enable = true;
        # xresources.enable = true;
        # zellij.enable = true;
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
}
