{
  pkgs,
  config,
  lib,
  sharedConfig,
  ...
}: {
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    intel-gpu-tools.enable = true; # TODO switch probably
  };

  environment = {
    # systemPackages = with pkgs.nvtopPackages; [intel];
    sessionVariables = {
      VK_ICD_FILENAMES = builtins.concatStringsSep ":" [
        "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json"
        "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
      ];
    };
  };
  specialisation = lib.mkIf sharedConfig.isLaptop {
    nvidia.configuration = {
      # https://github.com/niri-wm/niri/wiki/Nvidia
      # https://github.com/NVIDIA/egl-wayland/issues/126#issuecomment-2379945259
      environment.etc = {
        "nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
          builtins.toJSON
          {
            rules = [
              {
                pattern = {
                  feature = "procname";
                  matches = "niri";
                };
                profile = "Limit Free Buffer Pool On Wayland Compositors";
              }
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
      };
      services.xserver.videoDrivers = ["nvidia"];
      # environment.systemPackages = with pkgs.nvtopPackages; [nvidia];
      hardware = {
        nvidia-container-toolkit.mount-nvidia-executables = true;
        nvidia = {
          open = true;
          dynamicBoost.enable = true;
          nvidiaPersistenced = true;
          nvidiaSettings = true;
          powerManagement.enable = false;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          modesetting.enable = true;

          prime = {
            sync.enable = true;
            # reverseSync.enable = true;
            # offload.enable = true;
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
            # amdgpuBusId = "PCI:5@0:0:0"; # If you have an AMD iGPU
          };
        };
      };
    };
  };
}
