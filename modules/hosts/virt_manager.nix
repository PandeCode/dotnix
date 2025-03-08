{...}: {
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["shawn"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
