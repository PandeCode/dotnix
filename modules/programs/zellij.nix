{
config,
lib,
...
}: {
    home.sessionVariables = {
        ZELLIJ_AUTO_ATTACH = lib.mkForce "true";
        PING_HOST = "9.9.9.9"; # for a ping script
    };

    programs.zellij = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
    };

    xdg.configFile = {
        "zellij/config.kdl".source = ../../config/zellij/config.kdl;

        "zellij/layouts/default.kdl".source = ../../config/zellij/layouts/default.kdl;
        "zellij/plugins/zjstatus.wasm".source = builtins.fetchurl {
            url = "https://github.com/dj95/zjstatus/releases/download/v0.19.1/zjstatus.wasm";
            sha256 = "e87bfd986aa84c8b0c39c687bbf5634810d7df2832d53d32769b5b7961a75ecc";
        };
        "zellij/plugins/zjframes.wasm".source = builtins.fetchurl {
            url = "https://github.com/dj95/zjstatus/releases/download/v0.19.1/zjframes.wasm";
            sha256 = "481140bef1ee90ffcd92330d00abee1ecee5b5e84ebd6058429d461db1145ad5";
        };

        "zellij/shell/usage.sh".source = ../../config/zellij/shell/usage.sh;
        "zellij/shell/ping.sh".source = ../../config/zellij/shell/ping.sh;
        "zellij/shell/weather.sh".source = ../../config/zellij/shell/weather.sh;
        "zellij/shell/song.sh".source = ../../config/zellij/shell/song.sh;
        "zellij/shell/mem.sh".source = ../../config/zellij/shell/mem.sh;
    };
}
