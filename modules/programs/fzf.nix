{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.fzf;
in {
  home.sessionVariables = {
    # https://github.com/folke/tokyonight.nvim/blob/main/extras/fzf/tokyonight_night.sh
    FZF_DEFAULT_OPTS = "--highlight-line  --info=inline-right  --ansi  --layout=reverse  --border=none --color=bg+:#283457  --color=bg:#16161e  --color=border:#27a1b9  --color=fg:#c0caf5  --color=gutter:#16161e  --color=header:#ff9e64  --color=hl+:#2ac3de  --color=hl:#2ac3de  --color=info:#545c7e  --color=marker:#ff007c  --color=pointer:#ff007c  --color=prompt:#2ac3de  --color=query:#c0caf5:regular  --color=scrollbar:#27a1b9  --color=separator:#ff9e64  --color=spinner:#ff007c --preview 'fzf-preview.sh {}'";
    FORGIT_FZF_DEFAULT_OPTS = "--exact --border --cycle --reverse --height '80%'";
    FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  };
}
