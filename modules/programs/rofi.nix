{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    (
      writeShellScriptBin "rofi-wifi-menu" (builtins.readFile (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/zbaylin/rofi-wifi-menu/refs/heads/master/rofi-wifi-menu.sh";
        sha256 = "0gilv2q4l7synn1labwzw3bm4xy4h1z2l7kh1jhjyfxn3xpx7fnc";
      }))
    )
    (rofi.override {plugins = [rofi-emoji rofi-calc rofi-games rofi-power-menu rofi-mpd];})
    rofi-bluetooth
  ];

  programs = {
    rbw = {
      enable = true;
      settings.email = config.programs.git.userEmail;
      package = pkgs.rofi-rbw-wayland;
    };
  };
  xdg.configFile = {
    "rofi/nix.rasi".text = ''${builtins.readFile ../../config/rofi/config.rasi}'';
  };
}
