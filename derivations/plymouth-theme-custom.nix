{
  stdenvNoCC,
  ffmpeg,
  pngquant,
  video ?
    builtins.fetchurl {
      url = "https://github.com/PandeCode/dotnix/raw/refs/heads/media/bootanimations/visual.webm";
      sha256 = "1ivjiz02c35iim7wwd7v5aaggm083vn4asm3mmwam99czadr89jl";
    },
  firstNRemove ? 103,
  lastNRemove ? 124,
}: let
  backgroundTop = [0.08627450980392157 0.08627450980392157 0.08627450980392157];
  backgroundBottom = [0.08627450980392157 0.08627450980392157 0.08627450980392157];
  bgTop = x: builtins.toString (builtins.elemAt backgroundTop x);
  bgBot = x: builtins.toString (builtins.elemAt backgroundBottom x);
  n = builtins.toString firstNRemove;
  m = builtins.toString lastNRemove;

  images = stdenvNoCC.mkDerivation {
    name = "images-for-plymouth-custom";
    src = video;
    dontUnpack = true;
    nativeBuildInputs = [ffmpeg pngquant];
    buildPhase = ''
      frameCount=$(ffprobe -v error -count_frames \
        -select_streams v:0 -show_entries stream=nb_read_frames \
        -of csv=p=0 "$src")
      echo -n $((frameCount - ${n} - ${m})) > frameCount

      ffmpeg -i "$src" -vf "scale=1280:-1" -vcodec png -compression_level 9 progress-%04d.png
      find . -maxdepth 1 -name 'progress-*.png' -print0 |
        xargs -0 -n 1 -P "$(nproc)" pngquant --quality=65-80 --strip --force --ext .png
    '';

    installPhase = ''
      out_dir="$out/share/plymouth/images"
      mkdir -p "$out_dir"
      cp frameCount "$out_dir"

      total=$(ls progress-*.png | wc -l)
      end=$((total - ${m}))
      start=$(( ${n} + 1 ))

      echo "total=$total start=$start end=$end"

      if (( end < start )); then
        echo "Error: frame range is invalid (total=$total, n=${n}, m=${m})" >&2
        exit 1
      fi

      idx=0
      while IFS= read -r f; do
        printf -v newname "%s/progress-%d.png" "$out_dir" "$idx"
        cp "$f" "$newname"
        ((idx++))
      done < <(ls progress-*.png | sort | sed -n "$\{start},$\{end}p")
    '';
  };
in
  stdenvNoCC.mkDerivation rec {
    name = "plymouth-theme-custom";
    src = images;
    dontUnpack = true;
    buildPhase = ''
      frameCount=$(cat $src/share/plymouth/images/frameCount)
      mkdir -p src
      cp $src/share/plymouth/images/*.png src/
    '';

    installPhase =
      /*
      bash
      */
      ''
        out_dir=$out/share/plymouth/themes/${name}
        mkdir -p $out_dir
        mv src/* $out_dir

        cat > "$out_dir/${name}.script" <<EOF
        Window.SetBackgroundTopColor(${bgTop 0}, ${bgTop 1}, ${bgTop 2});
        Window.SetBackgroundBottomColor(${bgBot 0}, ${bgBot 1}, ${bgBot 2});

        for (i = 1; i < $frameCount; i++)
          custom_image[i] = Image("progress-" + i + ".png");
        custom_sprite = Sprite();

        custom_sprite.SetX(Window.GetWidth() / 2 - custom_image[0].GetWidth() / 2);
        custom_sprite.SetY(Window.GetHeight() / 2 - custom_image[0].GetHeight() / 2);

        progress = 0;

        fun refresh_callback () {
          custom_sprite.SetImage(custom_image[progress % $frameCount]);
          progress++;
        }
        Plymouth.SetRefreshFunction(refresh_callback);
        EOF


        cat > "$out_dir/${name}.plymouth" <<EOF
        [Plymouth Theme]
        Name=${name}
        Description=This is a Plymouth theme with a custom animation.
        ModuleName=script

        [script]
        ImageDir=$out_dir
        ScriptFile=$out_dir/${name}.script
        EOF
      '';
  }
