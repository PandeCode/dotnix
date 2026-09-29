{
  config,
  lib,
  ...
}:

let
  inherit (lib.modules)
    mkDefault
    mkForce
    mkIf
    mkMerge
    ;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;

  cfg = config.dotnix.hardware.nvidia;
  offload = cfg.mode == "offload";

  busId = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "PCI:1:0:0";
    description = "From `lspci -D`: 0000:01:00.0 is PCI:1:0:0 (the numbers are hex there, decimal here).";
  };
in

{
  options.dotnix.hardware.nvidia = {
    enable = mkEnableOption "an NVIDIA GPU";

    prime = {
      enable = mkEnableOption "PRIME, for laptops with a second, integrated GPU";
      intelBusId = busId;
      amdgpuBusId = busId;
      nvidiaBusId = busId;
    };

    mode = mkOption {
      type = types.enum [
        "offload"
        "sync"
      ];
      default = "offload";
      description = ''
        offload: the integrated GPU draws, the NVIDIA one sleeps until a
        program is started with nvidia-offload. sync: the NVIDIA GPU draws
        everything.
      '';
    };

    syncSpecialisation = mkEnableOption "a second boot entry, nvidia-sync, with the GPU always on";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        open = mkDefault true;
        nvidiaSettings = true;
        powerManagement.enable = true;
      };

      # https://github.com/niri-wm/niri/wiki/Nvidia: wayland compositors
      # otherwise hold on to a large pool of video memory
      environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
        builtins.toJSON {
          rules =
            map
              (procname: {
                pattern = {
                  feature = "procname";
                  matches = procname;
                };
                profile = "Limit Free Buffer Pool On Wayland Compositors";
              })
              [
                "niri"
                "river"
              ];
          profiles = [
            {
              name = "Limit Free Buffer Pool On Wayland Compositors";
              settings = [
                {
                  key = "GLVidHeapReuseRatio";
                  value = 0;
                }
              ];
            }
          ];
        };

      hardware.nvidia-container-toolkit.enable = mkDefault config.virtualisation.docker.enable;
    }

    (mkIf cfg.prime.enable {
      hardware.nvidia = {
        prime = {
          nvidiaBusId = mkIf (cfg.prime.nvidiaBusId != null) cfg.prime.nvidiaBusId;
          intelBusId = mkIf (cfg.prime.intelBusId != null) cfg.prime.intelBusId;
          amdgpuBusId = mkIf (cfg.prime.amdgpuBusId != null) cfg.prime.amdgpuBusId;
          offload = {
            enable = offload;
            enableOffloadCmd = offload;
          };
          sync.enable = !offload;
        };
        powerManagement.finegrained = offload;
        nvidiaPersistenced = !offload;
      };

      assertions = [
        {
          assertion =
            cfg.prime.nvidiaBusId != null && (cfg.prime.intelBusId != null || cfg.prime.amdgpuBusId != null);
          message = "dotnix.hardware.nvidia.prime needs nvidiaBusId and intelBusId or amdgpuBusId.";
        }
      ];
    })

    (mkIf (cfg.prime.enable && offload && cfg.syncSpecialisation) {
      specialisation.nvidia-sync.configuration = {
        dotnix.hardware.nvidia.mode = mkForce "sync";
        system.nixos.tags = [ "nvidia-sync" ];
      };
    })
  ]);
}
