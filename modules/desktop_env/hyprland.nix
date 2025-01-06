{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./widgets.nix
  ];

  programs = {
    hyprland = {
      enable = true;
      nvidiaPatches = true;
      xwayland.enable = true;
    };
  };
  hardware = {
    opengl.enable = true;
  };

  environment = {
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1"; # invisible cursor protection
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      rofi-wayland
      bemenu

      waybar

      swww
      # linux-wallpaperengine
      # hyprpaper
      # swaybg
      # wpaperd
      # mpvpaper
    ];
  };
}
