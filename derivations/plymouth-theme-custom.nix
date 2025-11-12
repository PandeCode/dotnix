{
  stdenvNoCC,
  ffmpeg,
  video ?
    builtins.fetchurl {
      url = "https://github.com/PandeCode/dotnix/raw/refs/heads/media/bootanimations/visual.webm";
      sha256 = "1ivjiz02c35iim7wwd7v5aaggm083vn4asm3mmwam99czadr89jl";
    },
}: let
  backgroundTop = [0.08627450980392157 0.08627450980392157 0.08627450980392157];
  backgroundBottom = [0.08627450980392157 0.08627450980392157 0.08627450980392157];
  bgTop = x: builtins.toString (builtins.elemAt backgroundTop x);
  bgBot = x: builtins.toString (builtins.elemAt backgroundBottom x);
in
  stdenvNoCC.mkDerivation {
    name = "plymouth-theme-custom";
    pname = "plymouth-theme-custom";
    src = null;
    dontUnpack = true;
    nativeBuildInputs = [ffmpeg];

    buildPhase = ''
      frameCount=$(${ffmpeg}/bin/ffprobe  -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 ${video})
      ffmpeg -i ${video} -vf "scale=1280:-1" -q:v 5 "progress-%d.jpg"

      cat > PlymouthTheme-Custom.script <<EOF
      Window.SetBackgroundTopColor (${bgTop 0}, ${bgTop 1}, ${bgTop 2});
      Window.SetBackgroundBottomColor (${bgBot 0}, ${bgBot 1}, ${bgBot 2}));

      for (i = 0; i < $frameCount; i++)
        flyingman_image[i] = Image("progress-" + i + ".jpg");
      flyingman_sprite = Sprite();

      flyingman_sprite.SetX(Window.GetWidth() / 2 - flyingman_image[0].GetWidth() / 2);
      flyingman_sprite.SetY(Window.GetHeight() / 2 - flyingman_image[0].GetHeight() / 2);

      progress = 0;

      fun refresh_callback ()
      {
        flyingman_sprite.SetImage(flyingman_image[progress%$frameCount]);
        progress++;
      }
      Plymouth.SetRefreshFunction (refresh_callback);
      EOF
    '';

    installPhase = ''
      cat > PlymouthTheme-Custom.plymouth <<EOF
      [Plymouth Theme]
      Name=PlymouthTheme-Custom
      Description=This is a Plymouth theme with a custom animation.
      ModuleName=script

      [script]
      ImageDir=$out/share/plymouth/themes/PlymouthTheme-Custom
      ScriptFile=$out/share/plymouth/themes/PlymouthTheme-Custom/PlymouthTheme-Custom.script
      EOF

      mkdir -p $out/share/plymouth/themes/PlymouthTheme-Custom
      cp PlymouthTheme-Custom.plymouth PlymouthTheme-Custom.script ./progress-* $out/share/plymouth/themes/PlymouthTheme-Custom
    '';
  }
