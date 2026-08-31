{
  pkgs,
  inputs,
  ...
}: let
  rill = let
    zig = pkgs.zig_0_16;
  in
    pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      name = "rill";
      src = inputs.rill;

      buildInputs = with pkgs; [
        wayland
        wayland-protocols
        wayland-scanner
        libxkbcommon
      ];
      nativeBuildInputs = [
        zig
        pkgs.pkg-config
      ];
      zigBuildFlags = [
        "--system"
        "${finalAttrs.deps}"
      ];

      strictDeps = true;
      # TODO this was annoying, just generate on flake updates
      deps = pkgs.callPackage (
        {
          linkFarm,
          fetchzip,
        }:
          linkFarm "zig-packages" [
            {
              name = "wayland-0.6.0-lQa1kqz8AQADQmdNJsNhLoNHcnEGEUjrOaPV-dtEnEmX";
              path = fetchzip {
                url = "https://codeberg.org/ifreund/zig-wayland/archive/v0.6.0.tar.gz";
                hash = "sha256-3m/ITNhZUJ/5uD/Tqm+0uZSktGoYgWF5oldOqOCUkIE=";
              };
            }
            {
              name = "xkbcommon-0.4.0-VDqIe0i2AgDRsok2GpMFYJ8SVhQS10_PI2M_CnHXsJJZ";
              path = fetchzip {
                url = "https://codeberg.org/ifreund/zig-xkbcommon/archive/v0.4.0.tar.gz";
                hash = "sha256-zQkmP/cuhAtjOLqYS5D15khKzpqyhbyZ0TD6/8jOkqE=";
              };
            }
          ]
      ) {};
    });
in {
  imports = [../wayland/home.nix];

  home.packages = [
    rill
  ];
  xdg.configFile = {
    "river/init" = {
      text = ''
        #!/bin/sh
        ${rill}/bin/rill
      '';
      executable = true;
    };
    "rill/config.zon" = let
      config = import ./config.nix;
      rillConfigPkg =
        pkgs.runCommandNoCC "rillConfigPkg" {
          CONFIG_JSON = builtins.toJSON config;
          nativeBuildInputs = with pkgs; [zig_0_16];
        } ''
          mkdir -p $out
          cat ${../../../bin/json2zon.zig} > json2zon.zig
          ZIG_GLOBAL_CACHE_DIR=$PWD/zig-cache zig build-exe json2zon.zig
          echo "$CONFIG_JSON" | ./json2zon --dot > $out/config.zon
          zig fmt $out/config.zon
        '';
    in {
      source = "${rillConfigPkg}/config.zon";
      onChange = ''
        notify-send "Home-manager" "Rebuild nix"
        killall -9 rill && rill & disown
      '';
    };
  };
}
