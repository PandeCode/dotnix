# vim-wordmotion
# eg, hello_world_this HelloWorldThis
{
  pkgs,
  sharedConfig,
  ...
}: {
  xdg.configFile."helix/init.scm".text = builtins.readFile ../../config/helix/init.scm;
  # xdg.configFile."helix/scm"= { recursive = true; source /home/${sharedConfig.user}/dotnix/config/helix/scm; }
  programs.helix = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "helix-with-tools";
      paths = with pkgs; [
        helix

        harper

        clang-tools
        ccls
        neocmakelsp

        rust-analyzer

        zls

        asm-lsp

        vscode-langservers-extracted
        yaml-language-server
        typescript-language-server
        prettier-d-slim

        steel
        steel-language-server

        lua-language-server # TODO
        emmylua-ls
        fennel-ls

        nixd # TODO config with nix

        bash-language-server
        fish-lsp

        haskell-language-server
        clojure-lsp
        lean

        tinymist
        typstyle
        texlab

        marksman # TODO
        markdown-oxide

        glsl_analyzer
        wgsl-analyzer
        wgpu-utils
      ];
    };
    ignores = [
      "zig-out"
      ".zig-cache/"
      "build/"
      ".build/"
      ".cache/"
      ".ccls*"
      ".clangd*"
      "!.gitignore"
    ];
    themes = {
      stylix = {
        rainbow = pkgs.lib.mkForce [
          "base04"
          "base05"
          "base06"
          "base07"
          "base08"
          "base09"
          "base0A"
          "base0B"
          "base0C"
          "base0D"
          "base0E"
          "base0F"
        ];
      };
    };
    settings = {
      # theme = "base16"; # stylix
      editor = {
        mouse = false;

        line-number = "relative";
        auto-format = true;
        true-color = true;
        scrolloff = 25;

        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "error";

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        soft-wrap. enable = true;
        # whitespace. render = "all";

        color-modes = true;
        statusline = {
          mode = {
            normal = "(・_・)";
            insert = "(っ•̀ω•́)っ";
            select = "(ᗒᗨᗕ)";
          };
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "╎"; # Some characters that work well: "▏", "┆", "┊", "⸽"
          skip-levels = 1;
        };
      };

      keys = {
        normal = {
          g.g = "goto_file_start";
          G = ["goto_last_line" "goto_line_end"];
          z.ret = "align_view_center";
          space."`" = "goto_last_accessed_file";
          t.i = ":toggle lsp.display-inlay-hints";

          "C-f" = ["align_view_bottom" "move_line_down"];
          "C-b" = ["align_view_top" "move_line_up"];

          # space.space = "file_picker";
          # space.w = ":w";
          # space.q = ":q";
          # esc = ["collapse_selection" "keep_primary_selection"];
        };
        insert = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
          pageup = "no_op";
          pagedown = "no_op";
          home = "no_op";
          end = "no_op";
        };
      };
    };
    # https://docs.helix-editor.com/languages.html
    languages = {
      language-server = {
        typescript-language-server = with pkgs; {
          command = "${typescript-language-server}/bin/typescript-language-server";
          args = ["--stdio" "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"];
          config = {
            format = {
              semicolons = "insert";
              insertSpaceBeforeFunctionParenthesis = true;
            };
          };
        };
        ccls = {command = "ccls";};
        matlab_ls = {
          command = "${pkgs.matlab-language-server}/bin/matlab-language-server";
          args = ["--stdio"];
          config = {
            MATLAB = {
              indexWorkspace = true;
              installPath = "/home/${sharedConfig.user}/apps/matlab/installation/";
              matlabConnectionTiming = "onStart";
              telemetry = true;
            };
          };
        };

        #(vim.lsp.config :matlab_ls
        #                 {:settings {:MATLAB {:indexWorkspace true
        #                                      :installPath (vim.fn.expand ")
        #                                      :matlabConnectionTiming :onStart
        #                                      :telemetry true}}})
        #
        # (vim.lsp.config :nixd
        #                 {:settings {:nixd {:nixpkgs {:expr (or vim.g.nix_nixd_nixpkgs
        #                                                        "import <nixpkgs> {}")}
        #                                    :options {:nixos {:expr vim.g.nix_nixd_nixos_options}
        #                                              :home-manager {:expr vim.g.nix_nixd_home_manager_options}}
        #                                    :formatting {:command [:nixfmt]}
        #                                    :diagnostic {:suppress [:sema-escaping-with]}}}})
      };

      language = [
        {
          name = "matlab";
          language-servers = ["matlab_ls"];
        }
        {
          name = "c";
          language-servers = ["ccls"];
        }
        {
          name = "cpp";
          language-servers = ["ccls"];
        }
        {
          name = "rust";
          auto-format = false;
        }
      ];
    };
  };
}
