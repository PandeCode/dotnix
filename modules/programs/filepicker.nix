{
  pkgs,
  sharedConfig,
  ...
}: let
  open-tui = pkgs.writeShellScriptBin "open-tui" ''
    #!/bin/bash
    tool=$1
    loc=$2
    loc=''${loc#"file://"}

    if [[ ! -e $loc ]]; then
        loc=$(dirname "$loc")
    fi

    ${sharedConfig.terminal} -e "$tool" "$loc"
  '';
in {
  programs = {
    ranger = {enable = true;};
    lf = {enable = true;};
    xplr = {enable = true;};
  };

  xdg = {
    mimeApps = {
      defaultApplications = {
        "inode/directory" = "xranger.desktop";
      };
    };
    desktopEntries = {
      xranger = {
        # X-MultipleArgs=false
        name = "xranger";
        genericName = "File Manager";
        comment = "Launches the ranger file manager";
        exec = "${open-tui}/bin/open-tui ranger %F";
        icon = "utilities-terminal";
        terminal = false;
        type = "Application";
        categories = ["System" "FileTools" "FileManager"];
        mimeType = ["inode/directory"];
        startupNotify = true;
      };
    };
  };
}
