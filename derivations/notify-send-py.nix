{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "notify-send-py";
  version = "1.2.7";
  pyproject = true;

  src = fetchPypi {
    pname = "notify-send.py";
    inherit version;
    hash = "sha256-9olZRJ9q1mx1hGqUal6XdlZX6v5u/H1P/UqVYiw9lmM=";
  };

  build-system = [
    python3.pkgs.flit-core
  ];

  dependencies = with python3.pkgs; [
    dbus-python
    pygobject3
  ];

  optional-dependencies = with python3.pkgs; {
    dev = [
      flit
      pygments
    ];
  };

  # pythonImportsCheck = [
  #   "notify_send_py"
  # ];

  meta = {
    description = "Script and module for sending desktop notifications";
    homepage = "https://pypi.org/project/notify-send.py/";
    license = with lib.licenses; [bsd2 mit];
    # maintainers = with lib.maintainers; [];
    mainProgram = "notify-send-py";
  };
}
