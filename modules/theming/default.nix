{pkgs, ...}: {
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.gruvbox-plus-icons;
      name = "GruvboxPlus;";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Mordern-Ice";
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };
  };
  qt = {
    enable = true;

    platformTheme = "gtk"; # or "gnome"
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };
}
