{sharedConfig, ...}: {
  home.file.".tmux.conf".text = ''
    set -g default-shell /run/current-system/sw/bin/${sharedConfig.shell}
    source ~/dotnix/config/tmux/.tmux.conf
  '';
}
