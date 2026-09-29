{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption;

  cfg = config.dotnix.hardware.amd;
in

{
  options.dotnix.hardware.amd = {
    enable = mkEnableOption "an AMD GPU";
    lact.enable = mkEnableOption "LACT, to monitor and tune the GPU" // {
      default = true;
    };
    # blender, pytorch and others only look in /opt/rocm
    rocm.enable = mkEnableOption "ROCm at /opt/rocm";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }

    (mkIf cfg.lact.enable { services.lact.enable = true; })

    (mkIf cfg.rocm.enable {
      systemd.tmpfiles.rules =
        let
          rocm = pkgs.symlinkJoin {
            name = "rocm";
            paths = with pkgs.rocmPackages; [
              clr
              hipblas
              rocblas
            ];
          };
        in
        [ "L+ /opt/rocm - - - - ${rocm}" ];
    })
  ]);
}
