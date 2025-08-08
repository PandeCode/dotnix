{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "virtual-monitor-env";

  buildInputs = with pkgs; [
    # X stuff
    xorg.xorgserver
    xorg.xrandr
    xorg.xinit
    xorg.xf86videodummy
    xorg.xauth
    xorg.xhost

    # Headless display & window management
    xpra
    xorg.xvfb
    i3
    xterm

    # Virtual webcam & streaming
    ffmpeg
    mesa
  ];

  shellHook = ''
    echo "[+] Virtual monitor environment ready."

    alias start-virtual-display='xpra start :100 --start-child=xterm'
    alias start-i3='DISPLAY=:100 i3'
    alias stop-virtual-display='xpra stop :100'

    alias setup-vcam="sudo modprobe v4l2loopback devices=1 video_nr=10 card_label='VirtualMonitor' exclusive_caps=1"
    alias teardown-vcam="sudo modprobe -r v4l2loopback"

    alias obs-vcam="obs --startvirtualcam"
    alias obs-screen="obs"

    echo
    echo "[Usage]"
    echo "  setup-vcam           # Create /dev/video10 virtual webcam"
    echo "  start-virtual-display # Start virtual X session on :100"
    echo "  start-i3             # Start i3 in virtual display"
    echo "  obs-vcam             # Stream display to Zoom via OBS virtual cam"
    echo "  stop-virtual-display  # Stop the virtual display session"
    echo "  teardown-vcam        # Remove virtual webcam module"
  '';
}
