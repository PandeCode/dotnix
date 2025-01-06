{pkgs, ...}: {
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  sound.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      (writeShellScriptBin "check_git_status.sh" ''${builtins.readFile ../../bin/check_git_status.sh}'')

      # (pkgs.warbar.overrideAttrs (oldAttrs: {
      #   mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      # }))

      dunst
      libnotify

      kitty
      wezterm
      alacritty
    ];
  };
}
