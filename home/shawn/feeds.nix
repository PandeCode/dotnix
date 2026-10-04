# shared by newsboat and the start page
[
  { url = "https://factorio.com/blog/rss"; }
]
++
  map
    (feed: {
      url = "https://${builtins.head feed}.xml";
      tags = builtins.tail feed;
    })
    [
      [
        "wpi-demolab.duckdns.org/rss"
        "graphics"
      ]
      [
        "blog.wybxc.cc/rss"
        "graphics"
      ]
      [
        "lyra.horse/blog/posts/index"
        "graphics"
      ]
      [
        "lisyarus.github.io/blog/feed"
        "graphics"
      ]
      [ "haskellforall.com/rss" ]
      [ "rexim.github.io/rss" ]
      [ "gram-editor.com/rss" ]
      [ "microzig.tech/devlog/devlog/rss" ]
      [ "ziglang.org/devlog/index" ]
    ]
