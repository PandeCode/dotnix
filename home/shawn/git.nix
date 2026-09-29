{
  programs = {
    git = {
      enable = true;
      signing.format = null;

      settings = {
        user = {
          name = "PandeCode";
          email = "pandeshawnbenjamin@gmail.com";
        };

        init.defaultBranch = "main";
        color.ui = "auto";

        alias = {
          p = "push";
          puhs = "push";
          psuh = "push";
          pshu = "push";
          sphu = "push";
          phsu = "push";

          ignore = "update-index --assume-unchanged";
          ignored = ''!git ls-files -v | grep "^[[:lower:]]"'';
          unignore = "update-index --no-assume-unchanged";
          squash = ''!f(){ git reset --soft HEAD~''${1} && git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"; };f'';

          lg = "log --all --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          l = "log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=short";
          a = "add";
          ap = "add -p";
          c = "commit --verbose";
          ca = "commit -a --verbose";
          cm = "commit -m";
          cam = "commit -a -m";
          m = "commit --amend --verbose";
          d = "diff";
          ds = "diff --stat";
          dc = "diff --cached";
          s = "status -s";
          sc = ''show --pretty="" --name-only HEAD'';
          co = "checkout";
          cob = "checkout -b";
          b = "for-each-ref --sort=-authordate --format='%(authordate)%09%(objectname:short)%09%(refname:short)' refs/heads";
          la = "config --get-regexp ^alias\\.";
        };
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };

    lazygit = {
      enable = true;
      settings.gui.nerdFontsVersion = "3";
    };
  };
}
