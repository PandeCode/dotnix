{pkgs, ...}: {
  programs.newsboat = {
    enable = true;
    autoFetchArticles.enable = true;
    urls =
      [
        {url = "https://factorio.com/blog/rss";}
      ]
      ++ (map (p: {
          tags = pkgs.lib.sublist 1 ((builtins.length p) - 1) p;
          url = "https://" + (builtins.elemAt p 0) + ".xml";
        }) [
          ["wpi-demolab.duckdns.org/rss" "graphics"]
          ["blog.wybxc.cc/rss" "graphics"]
          ["lyra.horse/blog/posts/index" "graphics"]
          ["lisyarus.github.io/blog/feed" "graphics"]
          ["haskellforall.com/rss"]
          ["rexim.github.io/rss"]
          ["gram-editor.com/rss"]

          ["microzig.tech/devlog/devlog/rss"]
          ["ziglang.org/devlog/index"]
        ]);
  };
}
