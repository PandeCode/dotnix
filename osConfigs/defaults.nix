{
  git.user = {
    name = "PandeCode";
    email = "pandeshawnbenjamin@gmail.com";
  };

  terminal = "ghostty";
  explorer = "nautilus";
  browser = "zen";
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

  shellAliases = {
    neo = "neovide $(fzf) 2>&1  > /dev/null & disown";
    ns = "nix-shell shell.nix --command 'fish'";
    nsp = "nix-shell --command 'fish' -p";

    gamescopehdr = "DXVK_HDR=1 gamescope -f --hdr-enabled -- ";
    steamhdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= ";
    winehdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= wine ";
    mpvhdr = "ENABLE_HDR_WSI=1 mpv --vo=gpu-next --target-colorspace-hint --gpu-api=vulkan --gpu-context=waylandvk ";

    ls = "ls --color=auto";
    sl = "ls --color=auto";
    l = "ls --color=auto -latr";
    j = "z";

    mkdir = "mkdir";
    mkdri = "mkdir";
    mkidr = "mkdir";
    mdkir = "mkdir";
    dmkir = "mkdir";
    cp = "cp -ir";
    free = "free -m";
    sizeof = "bash -c 'du -h --max-depth=0'";
    tree = "tre";

    clonec = "git clone --depth 1 --recurse-submodules --shallow-submodules --single-branch -j$(nproc) $(cso)";
    wgetc = "cso | xargs wget -c ";

    gti = "git";

    ":e" = "nvim";
    e = "nvim";
    ff = "bash -c 'selection=$(fzf --print0) && [ -n \"$selection\" ] && echo -n \"$selection\" | xargs -0 -o nvim'";
    ":q" = "exit";
    eixt = "exit";
    f = "fuck";
    nivm = "nvim";
    py = "python3";

    man = "batman";
    cls = "clear";
    tls = "clear ; tmux clear-history";
  };
}
