{
  pkgs,
  lib,
  config,
  ...
}: {
  options.greenclip = {
    commands = lib.mkOption {
      default = {
        copy = ''rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}' -theme /tmp/launcher.rasi'';
        paste = ''sh -c 'rofi -modi "clipboard:greenclip print" -show clipboard -run-command "{cmd}" -theme /tmp/launcher.rasi && sleep 0.5 && xdotool type "$(xclip -o -selection clipboard)"' '';
        restart = ''pkill greenclip && greenclip clear && greenclip daemon & disown'';
      };
    };
  };

  config = {
    home = {
      packages = [pkgs.haskellPackages.greenclip pkgs.xdotool];

      file.".config/greenclip.toml".text =
        # toml
        ''
          [greenclip]
          history_file = "/home/${config.home.username}/.cache/greenclip.history"
          max_history_length = 50
          max_selection_size_bytes = 0
          trim_space_from_selection = true
          use_primary_selection_as_input = false
          blacklisted_applications = []
          enable_image_support = true
          image_cache_directory = "/tmp/greenclip"
          static_history = []
        '';
    };
  };
}
