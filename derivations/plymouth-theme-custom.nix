{
  stdenvNoCC,
  ffmpeg,
  video,
  frames ? 100,
  BackgroundTopColor ? "(0.0, 0.00, 0.0)",
  BackgroundBottomColor ? "(0.0, 0.00, 0.0)",
}:
stdenvNoCC.mkDerivation {
  pname = "plymouth-theme-custom";
  version = "unstable-2025-05-05";

  src = null;
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ffmpeg];

  installPhase = ''
    outDir=$out/share/plymouth/themes/Custom
    mkdir -p "$outDir"

    cat > "$outDir/Custom.plymouth" <<EOF
        [Plymouth Theme]
        Name=Custom
        Description=Plymouth custom theme.
        ModuleName=script

        [script]
        ImageDir=/usr/share/plymouth/themes/Custom
        ScriptFile=/usr/share/plymouth/themes/Custom/Custom.script
    EOF

    cat > "$outDir/Custom.script" <<EOF
      Window.SetBackgroundTopColor ${BackgroundTopColor};
      Window.SetBackgroundBottomColor ${BackgroundBottomColor};

      # Image animation loop
      for (i = 1; i < ${toString (frames + 1)}; i++)
      flyingman_image[i] = Image("progress-" + i + ".png");
      flyingman_sprite = Sprite();

      #Place in the center
      flyingman_sprite.SetX(Window.GetWidth() / 2 - flyingman_image[1].GetWidth() / 2);
      flyingman_sprite.SetY(Window.GetHeight() / 2 - flyingman_image[1].GetHeight() / 2);

      progress = 1;

      fun refresh_callback ()
      {
      flyingman_sprite.SetImage(flyingman_image[Math.Int(progress / 3) % ${toString frames}]);
      progress++;
      }

      Plymouth.SetRefreshFunction (refresh_callback);
    EOF

    cd "$outDir"

    ffmpeg -i ${video} -vf "select=between(n\,0\,${toString (frames - 1)})" -vsync 0 progress-%d.png || :

    sed -i "s@\/usr\/@$out\/@" Custom.plymouth
  '';
}
