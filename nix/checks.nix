self: let
  inherit (self) inputs;
in
  system: {
    pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        alejandra.enable = true;
        check-added-large-files.enable = true;
        ripsecrets.enable = true;
        check-json.enable = true;
        check-shebang-scripts-are-executable.enable = true;
        check-symlinks.enable = true;
        check-toml.enable = true;
        check-yaml.enable = true;
        end-of-file-fixer.enable = true;
        mixed-line-endings.enable = true;
        prettier.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        trim-trailing-whitespace.enable = true;
      };
    };
  }
