{sharedConfig, ...}: {
  programs = {
    git = {
      enable = true;
      settings = {
        inherit (sharedConfig.git) user;
        init.defaultBranch = "main";
        color. ui = "auto";
        alias = {
          ignore = ''update-index --assume-unchanged'';
          ignored = ''!git ls-files -v | grep "^[[:lower:]]"'';
          unignore = ''update-index --no-assume-unchanged'';
          squash = ''!f(){ git reset --soft HEAD~$\{1} && git commit --edit -m\"$(git log --format=%B --reverse HEAD..HEAD@{1})\"; };f'';

          lg = ''log --all --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit'';
          l = ''log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'';
          a = ''add'';
          ap = ''add -p'';
          c = ''commit --verbose'';
          ca = ''commit -a --verbose'';
          cm = ''commit -m'';
          cam = ''commit -a -m'';
          m = ''commit --amend --verbose'';
          d = ''diff'';
          ds = ''diff --stat'';
          dc = ''diff --cached'';
          s = ''status -s'';
          sc = ''show --pretty="" --name-only HEAD'';
          co = ''checkout'';
          cob = ''checkout -b'';
          b = ''"!'git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'"'';
          la = ''"!git config -l | grep alias | cut -c 7-"'';
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
      settings = {
        # https://raw.githubusercontent.com/folke/tokyonight.nvim/refs/heads/main/extras/lazygit/tokyonight_night.yml
        gui = {
          nerdFontsVersion = "3";
          theme = {
            activeBorderColor = ["#ff9e64" "bold"];
            inactiveBorderColor = ["#27a1b9"];
            searchingActiveBorderColor = ["#ff9e64" "bold"];
            optionsTextColor = ["#7aa2f7"];
            selectedLineBgColor = ["#283457"];
            cherryPickedCommitFgColor = ["#7aa2f7"];
            cherryPickedCommitBgColor = ["#bb9af7"];
            markedBaseCommitFgColor = ["#7aa2f7"];
            markedBaseCommitBgColor = ["#e0af68"];
            unstagedChangesColor = ["#db4b4b"];
            defaultFgColor = ["#c0caf5"];
          };
        };
      };
    };
  };
}
