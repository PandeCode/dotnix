callPackage: {
  sddm-custom-theme = callPackage ../derivations/sddm-custom-theme.nix {};
  plymouth-theme-custom = callPackage ../derivations/plymouth-theme-custom.nix {};
  plymouth-cat-theme = callPackage ../derivations/plymouth-theme-cat.nix {};
  notify-send-py = callPackage ../derivations/notify-send-py.nix {};
}
