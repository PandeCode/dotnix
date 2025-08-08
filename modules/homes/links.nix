{
  config,
  lib,
  ...
}: let
  cfg = config.dotnix;
  homeDir = config.home.homeDirectory;

  # Function to expand ~ to home directory
  applyExpansion = path:
    if lib.hasPrefix "~/" path
    then "${homeDir}/${lib.removePrefix "~/" path}"
    else if path == "~"
    then homeDir
    else path;

  expandSymlinkPair = pair: [
    (applyExpansion (builtins.elemAt pair 0))
    (applyExpansion (builtins.elemAt pair 1))
  ];

  expandedSymlinkPairs = map expandSymlinkPair cfg.symlinkPairs;
in {
  options.dotnix = {
    symlinkPairs = lib.mkOption {
      type = lib.types.listOf (lib.types.listOf lib.types.str);
      default = [];
      example = [
        ["~/dotnix/config/picom/picom.conf" "~/.config/picom/picom.conf"]
        ["~/dotnix/config/nvim" "~/.config/nvim"]
      ];
      description = ''
        List of [source, destination] pairs to create symlinks.
        Each pair should be a list with exactly two strings: the source path and the destination path.
        Paths starting with ~/ will be expanded to the home directory.
      '';
    };

    enable = lib.mkEnableOption "dotnix symlink management";
  };

  config = lib.mkIf cfg.enable {
    home.activation.dotnixSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.concatStringsSep "\n" (builtins.map (
          p: ''
            src="${builtins.elemAt p 0}"
            dst="${builtins.elemAt p 1}"
            if [ ! -e "$src" ]; then
              echo "❌ Source file missing: $src" >&2
              continue
            fi
            dst_dir=$(dirname "$dst")
            mkdir -p "$dst_dir"
            if [ -L "$dst" ]; then
              current_target=$(readlink "$dst")
              if [ "$current_target" = "$src" ]; then
                echo "✅ Symlink already correct: $dst -> $src" >&2
                continue
              else
                echo "🔄 Updating broken symlink: $dst -> $src" >&2
                ln -sf "$src" "$dst"
              fi
            elif [ -e "$dst" ]; then
              echo "⚠️ Destination exists and is not a symlink: $dst. Skipping." >&2
              continue
            else
              echo "🔗 Creating symlink: $dst -> $src" >&2
              ln -s "$src" "$dst"
            fi
          ''
        )
        expandedSymlinkPairs)}
    '';
  };
}
