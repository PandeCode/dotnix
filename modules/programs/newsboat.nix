_: {
  programs.newsboat = {
    enable = true;
    autoFetchArticles.enable = true;
    urls = [
      {
        tags = ["dev" "coolperson"];
        url = "https://lyra.horse/blog/posts/index.xml";
      }
      {
        tags = ["dev" "coolperson"];
        url = "https://rexim.github.io/rss.xml";
      }
      {
        tags = ["dev" "coolperson"];
        url = "https://ziglang.org/devlog/index.xml";
      }
    ];
  };
}
