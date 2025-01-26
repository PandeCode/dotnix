{
  pkgs,
  lib,
}:
with pkgs;
  python3.pkgs.buildPythonApplication rec {
    pname = "notify-send-py";
    version = "1.2.7";
    pyproject = true;
    doCheck = false;
    strictDeps = false;

    src = fetchPypi {
      pname = "notify-send.py";
      inherit version;
      hash = "sha256-9olZRJ9q1mx1hGqUal6XdlZX6v5u/H1P/UqVYiw9lmM=";
    };

    build-system = [
      python3.pkgs.flit-core
    ];

    buildInputs = with pkgs; [
      gtk3
    ];

    nativeBuildInputs = with pkgs; [
      wrapGAppsHook
      gobject-introspection
    ];

    dependencies = with python3.pkgs;
    with pkgs; [
      pygobject3
      dbus-python
      glib
    ];

    optional-dependencies = with python3.pkgs; {
      dev = [
        flit
        pygments
      ];
    };

    meta = {
      description = "Script and module for sending desktop notifications";
      homepage = "https://pypi.org/project/notify-send.py/";
      license = with lib.licenses; [bsd2 mit];
      # maintainers = with lib.maintainers; [];
      mainProgram = "notify-send-py";
    };
  }
