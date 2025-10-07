{
  stdenvNoCC,
  ffmpeg,
  video, # Video file (e.g., fetched via fetchurl)
  # Background colors
  BackgroundTopColor ? "(0.0, 0.0, 0.0)",
  BackgroundBottomColor ? "(0.0, 0.0, 0.0)",
  # Video processing parameters
  cropMode ? "fullscreen", # Options: "fullscreen", "center", "fit", "stretch", "custom"
  customCrop ? null, # Format: "w:h:x:y" (e.g., "1920:1080:0:0")
  # Screen size and positioning
  screenWidthPercent ? 100, # Percentage of screen width to use (1-100)
  screenHeightPercent ? 100, # Percentage of screen height to use (1-100)
  positionX ? "center", # Options: "left", "center", "right", or pixel value
  positionY ? "center", # Options: "top", "center", "bottom", or pixel value
  # Frame extraction settings
  extractAllFrames ? true, # If false, use maxFrames limit
  maxFrames ? 100, # Maximum frames to extract (ignored if extractAllFrames is true)
  frameRate ? null, # Override frame rate (null for auto-detect)
  # Animation settings
  animationSpeed ? 3, # Higher = slower animation (frames per refresh)
  loopAnimation ? true, # Whether to loop the animation
  # Image processing
  imageFormat ? "png", # Output format: "png", "jpg"
  imageQuality ? 95, # JPEG quality (1-100, ignored for PNG)
  backgroundColor ? "transparent", # Background for transparent areas: "transparent", "black", "white", or hex color
  # Advanced options
  enableAntialiasing ? true,
  enableUpscaling ? false, # Upscale small videos
  upscaleAlgorithm ? "lanczos", # Options: "lanczos", "bicubic", "bilinear"
}: let
  # Build video filter string based on parameters
  buildVideoFilter = let
    # Crop filter
    cropFilter =
      if cropMode == "fullscreen"
      then "scale=iw*max(1920/iw\\,1080/ih):ih*max(1920/iw\\,1080/ih),crop=1920:1080"
      else if cropMode == "center"
      then "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080"
      else if cropMode == "fit"
      then "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:${backgroundColor}"
      else if cropMode == "stretch"
      then "scale=1920:1080"
      else if cropMode == "custom" && customCrop != null
      then "crop=${customCrop}"
      else "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:${backgroundColor}";

    # Size adjustment filter
    sizeFilter =
      if screenWidthPercent != 100 || screenHeightPercent != 100
      then ",scale=iw*${toString screenWidthPercent}/100:ih*${toString screenHeightPercent}/100"
      else "";

    # Upscaling filter
    upscaleFilter =
      if enableUpscaling
      then ",scale=iw*2:ih*2:flags=${upscaleAlgorithm}"
      else "";

    # Anti-aliasing filter
    aaFilter =
      if enableAntialiasing
      then ",unsharp=5:5:1.0:5:5:0.0"
      else "";
  in "${cropFilter}${sizeFilter}${upscaleFilter}${aaFilter}";

  # Extract video metadata using ffprobe
  videoInfo = stdenvNoCC.mkDerivation {
    name = "video-info";
    src = null;
    dontUnpack = true;
    nativeBuildInputs = [ffmpeg];
    buildPhase = ''
      ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames,r_frame_rate,duration,width,height -of json ${video} > $out
    '';
  };

  # Read JSON output from ffprobe
  videoMetadata = builtins.fromJSON (builtins.readFile videoInfo);
  stream = builtins.elemAt videoMetadata.streams 0;

  # Calculate frame information
  detectedFrameCount = stream.nb_frames or null;
  detectedFrameRate = let
    rate = stream.r_frame_rate or "30/1";
    parts = builtins.split "/" rate;
    num = builtins.fromJSON (builtins.head parts);
    den = builtins.fromJSON (builtins.elemAt parts 2);
  in
    if den != 0
    then (num / den)
    else 30;

  duration = stream.duration or null;
  videoWidth = stream.width or 1920;
  videoHeight = stream.height or 1080;

  # Determine final frame count and rate
  finalFrameRate =
    if frameRate != null
    then frameRate
    else detectedFrameRate;
  finalFrameCount =
    if extractAllFrames
    then
      (
        if detectedFrameCount != null
        then builtins.fromJSON (toString detectedFrameCount)
        else if duration != null
        then builtins.ceil (builtins.fromJSON (toString duration) * finalFrameRate)
        else maxFrames
      )
    else maxFrames;

  # Generate positioning script
  positionScript = let
    xPos =
      if positionX == "left"
      then "0"
      else if positionX == "center"
      then "Window.GetWidth() / 2 - flyingman_image[1].GetWidth() / 2"
      else if positionX == "right"
      then "Window.GetWidth() - flyingman_image[1].GetWidth()"
      else toString positionX;

    yPos =
      if positionY == "top"
      then "0"
      else if positionY == "center"
      then "Window.GetHeight() / 2 - flyingman_image[1].GetHeight() / 2"
      else if positionY == "bottom"
      then "Window.GetHeight() - flyingman_image[1].GetHeight()"
      else toString positionY;
  in {
    x = xPos;
    y = yPos;
  };
in
  stdenvNoCC.mkDerivation {
    pname = "plymouth-theme-custom";
    version = "unstable-2025-09-11";

    src = null;
    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = [ffmpeg];

    installPhase = ''
          outDir=$out/share/plymouth/themes/Custom
          mkdir -p "$outDir"

          # Create Plymouth theme configuration
          cat > "$outDir/Custom.plymouth" <<EOF
      [Plymouth Theme]
      Name=Custom
      Description=Plymouth custom boot animation with configurable parameters.
      ModuleName=script

      [script]
      ImageDir=$out/share/plymouth/themes/Custom
      ScriptFile=$out/share/plymouth/themes/Custom/Custom.script
      EOF

          # Generate Plymouth script
          cat > "$outDir/Custom.script" <<EOF
      # Set background colors
      Window.SetBackgroundTopColor ${BackgroundTopColor};
      Window.SetBackgroundBottomColor ${BackgroundBottomColor};

      # Load animation frames
      for (i = 1; i <= ${toString finalFrameCount}; i++)
        flyingman_image[i] = Image("frame-" + i + ".${imageFormat}");

      flyingman_sprite = Sprite();

      # Position the animation
      flyingman_sprite.SetX(${positionScript.x});
      flyingman_sprite.SetY(${positionScript.y});

      # Animation variables
      progress = 1;
      frame_counter = 1;

      # Animation refresh function
      fun refresh_callback ()
      {
        current_frame = Math.Int((progress / ${toString animationSpeed}) % ${toString finalFrameCount}) + 1;
        flyingman_sprite.SetImage(flyingman_image[current_frame]);

        ${
        if loopAnimation
        then "progress++;"
        else ''
          if (progress < ${toString (finalFrameCount * animationSpeed)})
            progress++;
        ''
      }
      }

      Plymouth.SetRefreshFunction (refresh_callback);

      # Optional: Add fade-in effect
      fun boot_progress_callback (duration, progress)
      {
        # You can add boot progress effects here
      }

      Plymouth.SetBootProgressFunction (boot_progress_callback);
      EOF

          cd "$outDir"

          # Extract frames from video with all specified parameters
          echo "Extracting ${toString finalFrameCount} frames from video..."
          echo "Video dimensions: ${toString videoWidth}x${toString videoHeight}"
          echo "Using filter: ${buildVideoFilter}"

          ${
        if imageFormat == "png"
        then ''
          ffmpeg -i ${video} \
            -vf "${buildVideoFilter}" \
            -r ${toString (finalFrameCount
            / (
              if duration != null
              then builtins.fromJSON (toString duration)
              else 10
            ))} \
            -frames:v ${toString finalFrameCount} \
            -y \
            "frame-%d.png"
        ''
        else ''
          ffmpeg -i ${video} \
            -vf "${buildVideoFilter}" \
            -r ${toString (finalFrameCount
            / (
              if duration != null
              then builtins.fromJSON (toString duration)
              else 10
            ))} \
            -frames:v ${toString finalFrameCount} \
            -q:v ${toString (101 - imageQuality)} \
            -y \
            "frame-%d.jpg"
        ''
      }

          # Verify frames were created
          frame_count=$(ls frame-*.${imageFormat} 2>/dev/null | wc -l)
          if [ "$frame_count" -eq 0 ]; then
            echo "Error: No frames were extracted from the video" >&2
            exit 1
          fi
          echo "Successfully extracted $frame_count frames"

          # Create a preview script for testing
          cat > "$outDir/preview-info.txt" <<EOF
      Plymouth Theme Configuration:
      ============================
      Video Source: ${video}
      Original Dimensions: ${toString videoWidth}x${toString videoHeight}
      Crop Mode: ${cropMode}
      Screen Coverage: ${toString screenWidthPercent}% x ${toString screenHeightPercent}%
      Position: ${positionX}, ${positionY}
      Frame Count: ${toString finalFrameCount}
      Frame Rate: ${toString finalFrameRate} fps
      Animation Speed: ${toString animationSpeed}
      Loop Animation: ${toString loopAnimation}
      Image Format: ${imageFormat}
      Background: ${backgroundColor}

      Filter Chain: ${buildVideoFilter}
      EOF
    '';

    meta = {
      description = "Configurable Plymouth boot animation theme";
      longDescription = ''
        A highly configurable Plymouth theme that supports various cropping modes,
        positioning options, frame extraction settings, and animation parameters.
        Supports fullscreen, center-crop, fit, stretch, and custom crop modes.
      '';
    };
  }
