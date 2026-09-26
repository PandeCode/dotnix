{
  programs.eww = {
    enable = true;
    scssConfig = builtins.readFile ../../config/eww/eww.scss;
    yuckConfig = builtins.readFile ../../config/eww/eww.yuck;
  };
}
