{...}: let
in {
  # xdg.configFile = {
  # "swaync/rc.lua".text = builtins.readFile ../../config/swaync/style.css;
  # "swaync/rc.lua".text = builtins.readFile ../../config/swaync/style.css;
  # "swaync/rc.lua".text = builtins.readFile ../../config/swaync/style.css;
  # };
  services = {
    swaync = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ../../config/swaync/config.json);
    };
  };
}
