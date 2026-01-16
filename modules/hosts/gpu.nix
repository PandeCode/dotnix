{
  pkgs,
  config,
  lib,
  # sharedConfig,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs.nvtopPackages; [intel];
  environment.sessionVariables = {
    VK_ICD_FILENAMES = builtins.concatStringsSep ":" [
      "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json"
      "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
    ];
  };
  specialisation = lib.mkIf config.services.isLaptop {
    nvidia.configuration = {
      services.xserver.videoDrivers = ["nvidia"];
      environment.systemPackages = with pkgs.nvtopPackages; [nvidia];
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
          };
        };
      };
    };
  };
}
