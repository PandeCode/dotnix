{
  config,
  lib,
  ...
}: let
  username = config.home.username;
  homeDir = "/home/${username}";

  symlinkPairs = [
    ["${homeDir}/dotnix/config/picom/picom.conf" "${homeDir}/.config/picom/picom.conf"]
  ];
in {
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
      symlinkPairs)}
  '';
}
