rec {
  git.user = {
    name = "PandeCode";
    email = "pandeshawnbenjamin@gmail.com";
  };

  shell = "fish";
  terminal = "ghostty";
  explorer = "nautilus";
  browser = "chromium";
  editor = "nvim";

  isLaptop = false;
  isWSL = false;

  virt_manager.enable = false;
  osx-kvm.enable = false;

  wms = {
    sway.enable = false;
    i3.enable = true;
    river.enable = false;
    niri.enable = true; # issue https://github.com/sodiboo/niri-flake/issues/1018
    # dwm.enable = true;
    # xmonad.enable = true;
    # bspwm.enable = true;
    # awesomewm.enable = true;
  };

  gaming = {
    enable = false;
    epic = false;
    minecraft = false;
    osu = false;
    ps2 = false;
    switch = false;
    wallpaperengine = false;
    wii = false;
  };

  fishShellAliases = {
    j = "z";
  };

  fishShellAbbrs = {
    ssh = "ghostty +ssh --";

    lsblk = "lsblk | bat -l conf -p";
    ps = "ps | bat -l conf -p";
    lscpu = "lscpu | bat -l cpuinfo -p";
    sensors = "sensors | bat -l cpuinfo -p";

    dirflake = "echo 'use flake' > .envrc; direnv allow";
    dirnix = "echo 'use nix' > .envrc; direnv allow";
    neo = "neovide $(fzf) 2>&1  > /dev/null & disown";
    ns = "nix-shell shell.nix --command 'fish'";
    nsp = "NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nix-shell --command 'fish' -p";

    gamescopehdr = "DXVK_HDR=1 gamescope -f --hdr-enabled -- ";
    steamhdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= ";
    winehdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= wine ";
    mpvhdr = "ENABLE_HDR_WSI=1 mpv --vo=gpu-next --target-colorspace-hint --gpu-api=vulkan --gpu-context=waylandvk ";

    ls = "ls --color=auto";
    sl = "ls --color=auto";
    l = "ls --color=auto -latr";

    mkdir = "mkdir";
    mkdri = "mkdir";
    mkidr = "mkdir";
    mdkir = "mkdir";
    dmkir = "mkdir";
    cp = "cp -ir";
    free = "free -h";
    sizeof = "bash -c 'du -h --max-depth=0'";
    tree = "tre";

    clonec = "git clone --depth 1 --recurse-submodules --shallow-submodules --single-branch --filter=blob:none -j$(nproc) $(cso)";
    wgetc = "cso | xargs wget -c ";

    gti = "git";

    ":e" = "nvim";
    ":E" = "nvim";
    e = "nvim";
    ":q" = "exit";
    ":Q" = "exit";
    eixt = "exit";
    f = "fuck";
    nivm = "nvim";
    py = "python3";

    man = "batman";
    cls = "clear";
    tls = "clear ; tmux clear-history";
    les = "less";

    mkae = "make";
  };

  shellAliases =
    fishShellAbbrs
    // fishShellAliases;
}
