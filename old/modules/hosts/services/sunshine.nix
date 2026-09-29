{pkgs, ...}: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = false;
    capSysAdmin = true;

    settings = {
      sunshine_name = "nixos";
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # your Open GL, Vulkan and VAAPI drivers
      vpl-gpu-rt # for newer GPUs on NixOS &gt;24.05 or unstable
      # onevpl-intel-gpu  # for newer GPUs on NixOS &lt;= 24.05
      # Below was required for intel Arc GPU's
      # intel-media-driver
      # intel-media-sdk   # for older GPUs
    ];
  };
}
