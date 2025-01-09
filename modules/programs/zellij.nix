{
  config,
  lib,
  ...
}: {
  options = {
    zellij.enable = lib.mkEnableOption "enables zellij";
  };
  config = lib.mkIf config.zellij.enable {
    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    home.file = {
      ".config/zellij/config.kdl".source = ../../config/zellij/config.kdl;

      ".config/zellij/layouts/default.kdl".source = ../../config/zellij/layouts/default.kdl;

      ".config/zellij/plugins/zjstatus.wasm".source = builtins.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.19.1/zjstatus.wasm";
        sha256 = "e87bfd986aa84c8b0c39c687bbf5634810d7df2832d53d32769b5b7961a75ecc";
      };
      ".config/zellij/plugins/zjframes.wasm".source = builtins.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.19.1/zjframes.wasm";
        sha256 = "481140bef1ee90ffcd92330d00abee1ecee5b5e84ebd6058429d461db1145ad5";
      };

      ".config/zellij/shell/usage.sh".source = ../../config/zellij/shell/usage.sh;
      ".config/zellij/shell/ping.sh".source = ../../config/zellij/shell/ping.sh;
      ".config/zellij/shell/weather.sh".source = ../../config/zellij/shell/weather.sh;
      # ".config/zellij/shell/song.sh".source = ../../config/zellij/shell/song.sh;
      ".config/zellij/shell/mem.sh".source = ../../config/zellij/shell/mem.sh;
    };
  };
}
