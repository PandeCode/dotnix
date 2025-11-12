_: {
  home.file.".tmux.conf".text =
    /*
    sh
    */
    "
    set -g default-shell /run/current-system/sw/bin/fish
    source ~/dotnix/config/tmux/.tmux.conf
    ";
}
