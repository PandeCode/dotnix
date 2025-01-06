{pkgs, ...}: {
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  systemd.services.autostart = {
    description = "Backlight and kernel settings configuration";
    serviceConfig = {
      User = "root";
      ExecStart = ''
        sudo -E chmod 777 /sys/class/backlight/intel_backlight/brightness
        sudo sysctl dev.i915.perf_stream_paranoid=0
        sudo sysctl -w abi.vsyscall32=0
      '';
      WantedBy = ["multi-user.target"];
    };
  };
}
