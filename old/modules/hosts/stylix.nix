{
  pkgs,
  config,
  ...
}: {
  environment.sessionVariables = let
    c = config.lib.stylix.colors;
  in {
    STYLIX_FONT = config.stylix.fonts.sansSerif.name;

    STYLIX_BASE00 = c.base00;
    STYLIX_BASE01 = c.base01;
    STYLIX_BASE02 = c.base02;
    STYLIX_BASE03 = c.base03;
    STYLIX_BASE04 = c.base04;
    STYLIX_BASE05 = c.base05;
    STYLIX_BASE06 = c.base06;
    STYLIX_BASE07 = c.base07;
    STYLIX_BASE08 = c.base08;
    STYLIX_BASE09 = c.base09;
    STYLIX_BASE0A = c.base0A;
    STYLIX_BASE0B = c.base0B;
    STYLIX_BASE0C = c.base0C;
    STYLIX_BASE0D = c.base0D;
    STYLIX_BASE0E = c.base0E;
    STYLIX_BASE0F = c.base0F;

    STYLIX_BLACK = c.base00;
    STYLIX_WHITE = c.base07;
    STYLIX_RED = c.base08;
    STYLIX_GREEN = c.base0B;
    STYLIX_BLUE = c.base0D;
    STYLIX_YELLOW = c.base0A;
  };

  stylix =
    (import ../stylix/common.nix {inherit pkgs;}).stylix
    // {
      targets = {
        chromium.enable = true; # GUI
        console.enable = true;
        feh.enable = true;
        fish.enable = true;

        gnome-text-editor.enable = true;
        gnome.enable = true;
        grub.enable = false;
        grub.useWallpaper = true;

        gtk.enable = true;
        kmscon.enable = true;
        nixos-icons.enable = true;

        regreet.enable = false;
        lightdm.enable = false;
        nixvim.enable = false;
        plymouth.enable = false;
      };
    };
}
