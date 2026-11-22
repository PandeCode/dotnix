# alt+d closes the tab in librewolf and ungoogled-chromium. neither browser
# lets you rebind its own keys, but both let an extension's shortcut win
{
  lib,
  stdenvNoCC,
  python3,
}:

let
  # chromium takes the id from the key that signs the crx, so key.pem is only
  # here to keep the id the same. the build checks it
  chromiumId = "aimdohkfbkipnjjbmhlijaleeahmpdod";
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "browser-keys";
  version = (lib.trivial.importJSON ./extension/manifest.json).version;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./extension
      ./key.pem
      ./pack.py
    ];
  };

  nativeBuildInputs = [ (python3.withPackages (ps: [ ps.cryptography ])) ];

  installPhase = ''
    runHook preInstall
    id=$(python3 pack.py extension key.pem $out)
    if [ "$id" != ${chromiumId} ]; then
      echo "key.pem gives the id $id, package.nix says ${chromiumId}" >&2
      exit 1
    fi
    runHook postInstall
  '';

  passthru = {
    inherit chromiumId;
    firefoxId = (lib.trivial.importJSON ./extension/manifest.json).browser_specific_settings.gecko.id;
    crx = "${finalAttrs.finalPackage}/browser-keys.crx";
    xpi = "${finalAttrs.finalPackage}/browser-keys.xpi";
  };

  meta = {
    description = "Browser extension that closes the tab on Alt+D";
    platforms = lib.platforms.all;
  };
})
