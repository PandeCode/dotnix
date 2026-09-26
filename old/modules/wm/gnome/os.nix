# https://wiki.nixos.org/wiki/GNOME
{pkgs, ...}: {
  # services.displayManager.gdm.enable = true;
  services = {
    desktopManager.gnome.enable = true;
    gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
      games.enable = false;
    };
  };
  environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-user-docs];
}
