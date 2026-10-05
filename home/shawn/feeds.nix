# shared by newsboat, the start page and news.<domain>
let
  feed = url: tags: { inherit url tags; };
  youtube = id: feed "https://www.youtube.com/feeds/videos.xml?channel_id=${id}";
in

[
  (feed "https://factorio.com/blog/rss" [ ])

  (feed "https://wpi-demolab.duckdns.org/rss.xml" [ "graphics" ])
  (feed "https://blog.wybxc.cc/rss.xml" [ "graphics" ])
  (feed "https://lyra.horse/blog/posts/index.xml" [ "graphics" ])
  (feed "https://lisyarus.github.io/blog/feed.xml" [ "graphics" ])
  (feed "https://raphlinus.github.io/feed.xml" [ "graphics" ])
  (feed "https://ciechanow.ski/atom.xml" [ "graphics" ])
  (youtube "UCdmAhiG8HQDlz8uyekw4ENw" [ "graphics" ]) # inigo quilez
  (youtube "UCmtyQOKKmrMVaKuRXz02jbQ" [ "graphics" ]) # sebastian lague

  (feed "https://haskellforall.com/rss.xml" [ "haskell" ])
  (feed "https://lexi-lambda.github.io/feeds/all.atom.xml" [ "haskell" ])

  (feed "https://michael.stapelberg.ch/feed.xml" [ "nix" ])
  (feed "https://jade.fyi/rss.xml" [ "nix" ])
  (feed "https://xeiaso.net/blog.rss" [ "nix" ])

  (feed "https://rexim.github.io/rss.xml" [ ])
  (feed "https://gram-editor.com/rss.xml" [ ])
  (feed "https://microzig.tech/devlog/devlog/rss.xml" [ "zig" ])
  (feed "https://ziglang.org/devlog/index.xml" [ "zig" ])
  (feed "https://andrewkelley.me/rss.xml" [ "zig" ])
  (feed "https://kristoff.it/index.xml" [ "zig" ])
  (feed "https://mitchellh.com/feed.xml" [ "zig" ])
  (feed "https://www.dgtlgrove.com/feed" [ "zig" ]) # ryan fleury
  (youtube "UCz-yrxeZYIYdpEZgHGvIydA" [ "zig" ]) # nic barker
]
