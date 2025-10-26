{pkgs, ...}: {
  home.packages = with pkgs; [
    pipr
    whois
    holehe
    lemmeknow
    nmap
    rustscan
    rustcat
    binwalk
    # aircrack-ng
    # john
    sshs

    nasm
    radare2
    aflplusplus
    pwntools
    legba

    # qemu_full

    # https://www.blackarch.org/tools.html
  ];
}
