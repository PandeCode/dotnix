# vim-wordmotion
# eg, hello_world_this HelloWorldThis
{
  pkgs,
  config,
  ...
}: {
  programs.helix = {
    enable = true;
    package = pkgs.helix.overrideAttrs (_: {
      buildInputs = with pkgs; [
        harper

        clang-tools
        ccls
      ];
    });
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

        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "error";

        lsp.display-messages = true;

        # rainbow-brackets = true; # wtf
        soft-wrap. enable = true;
        whitespace. render = "all";

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

      keys.normal = {
        # space.space = "file_picker";
        # space.w = ":w";
        # space.q = ":q";
        # esc = ["collapse_selection" "keep_primary_selection"];
      };
    };
  };
}
