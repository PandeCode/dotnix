{pkgs, ...}: let
  mkBoxTool = pname: (
    pkgs.runCommandCC pname
    {
      inherit pname;
      code = builtins.readFile ../../src/${pname}.c;
      executable = true;
      passAsFile = ["code"];
      preferLocalBuild = true;
      allowSubstitutes = false;
      meta = {mainProgram = pname;};
    }
    ''
      n=$out/bin/${pname}
      mkdir -p "$(dirname "$n")"
      mv "$codePath" code.c
      unset NIX_ENFORCE_NATIVE
      CFLAGS="-std=c11 -O3 -march=native -mtune=native -flto -fwhole-program -fomit-frame-pointer -ffast-math -funroll-loops -finline-functions -fno-stack-protector -DNDEBUG -s -Wno-implicit-function-declaration"
      LDFLAGS="$LDFLAGS -flto -Wl,-O1 -Wl,--as-needed -Wl,--gc-sections -s"

      $CC -x c code.c -o "$n" $CFLAGS $LDFLAGS
    ''
  );
  mkZBoxTool = name: (
    pkgs.stdenv.mkDerivation {
      inherit name;
      src = builtins.readFile ../../src/${name}.zig;
      buildInputs = with pkgs; [zig_0_16];
      buildPhase = ''zig build-exe $src -o ${name}'';
      installPhase = ''
        mkdir -p $out/bin
        mv ${name} $out/bin
      '';
    }
  );
in {
  environment.systemPackages = [
    (mkBoxTool "contpid")
    (mkBoxTool "sizes")
    (mkZBoxTool "bg")
  ];
}
