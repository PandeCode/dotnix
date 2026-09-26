# there are alot of decisions here that could be imperatively overridden by literally pulling out the gpu
# i don't want to configure the permutations of specialisations so for now ill just behave
{
  pkgs,
  config,
  lib,
  ...
} @ args: let
  is = attrSet: attr:
    if (attr ? attrSet && builtins.typeOf (builtins.getAttr attr attrSet) == "bool")
    then (builtins.getAttr attr attrSet)
    else false;
  andSet = attrSet: list: builtins.foldl' (acc: el: (is attrSet el) && acc) true list;

  sharedConfig =
    if args ? "sharedConfig"
    then args.sharedConfig
    else {
      framework = false;
      isLaptop = false;
      isNvidia = false;
    };
in
  {
    imports = [
      (let
        isAmdLaptop = true; # TODO
      in
        lib.mkIf isAmdLaptop {
          services.lact.enable = true;
          systemd.tmpfiles.rules = let
            rocmEnv = pkgs.symlinkJoin {
              name = "rocm-combined";
              paths = with pkgs.rocmPackages; [
                rocblas
                hipblas
                clr
              ];
            };
          in [
            "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
          ];
        })
    ];

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
          "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
          "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
        ];
      };
    };
  }
  // {
    specialisation = let
      isNvidiaLaptop = andSet sharedConfig ["isLaptop" "isNvidia"];
    in
      lib.mkIf isNvidiaLaptop {
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
                offload.enable = false;
                intelBusId = "PCI:0:2:0";
                nvidiaBusId = "PCI:1:0:0";
                # amdgpuBusId = "PCI:5@0:0:0"; # If you have an AMD iGPU
              };
            };
          };
        };
      };
  }
