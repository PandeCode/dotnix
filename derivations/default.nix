callPackage: {
  sddm-custom-theme = callPackage ../derivations/sddm-custom-theme.nix {};
  # plymouth-theme-custom = callPackage ../derivations/plymouth-theme-custom.nix {};
  plymouth-theme-cat = callPackage ../derivations/plymouth-theme-cat.nix {};
  notify-send-py = callPackage ../derivations/notify-send-py.nix {};
  grub-custom-theme = callPackage ../derivations/grub-custom-theme.nix {};
}
