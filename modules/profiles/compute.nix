# a machine other projects run heavy work on: the gpu ready for cuda, a
# cache so cuda packages download instead of compile, and room for big files.
# what runs is up to each project's own flake
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkDefault mkIf;
  inherit (config.dotnix) user;

  cfg = config.dotnix.profiles.compute;
in

{
  options.dotnix.profiles.compute = {
    enable = lib.options.mkEnableOption "running heavy work for projects";

    scratch = lib.options.mkOption {
      type = lib.types.str;
      default = "/srv/data";
      description = "A folder of yours for models, datasets and the like, best on a big drive.";
    };
  };

  config = mkIf cfg.enable {
    # projects build with cudaSupport in their own nixpkgs; this is where
    # those builds come from
    dotnix.nix.caches = [
      {
        url = "https://cache.nixos-cuda.org";
        key = "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";
      }
    ];

    users.users.${user}.extraGroups = [
      "video"
      "render"
      "docker"
    ];

    # images that need the gpu: docker run --device nvidia.com/gpu=all
    virtualisation.docker = {
      enable = mkDefault true;
      daemon.settings.data-root = "${cfg.scratch}/docker";
    };

    # the big drive mounts with nofail; docker waits for it or doesn't start
    systemd.services.docker.unitConfig.RequiresMountsFor = [ cfg.scratch ];

    # binaries that pip and friends download
    programs.nix-ld.enable = true;

    environment.systemPackages = lib.lists.optional config.dotnix.hardware.nvidia.enable pkgs.nvtopPackages.nvidia;

    systemd.tmpfiles.rules = [ "d ${cfg.scratch} 0755 ${user} users -" ];
  };
}
