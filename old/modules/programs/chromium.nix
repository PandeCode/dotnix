{
  pkgs,
  lib,
  ...
}: {
  programs.chromium = let
    createChromiumExtensionFor = browserVersion: {
      id,
      sha256,
      version,
    }: {
      inherit id version;
      crxPath = builtins.fetchurl {
        url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
        name = "${id}.crx";
        inherit sha256;
      };
    };
    createChromiumExtension = createChromiumExtensionFor (lib.versions.major pkgs.ungoogled-chromium.version);
    ublock = rec {
      id = "hifpfkolgdolnmfmncmfocfiiaofjikk";
      version = "1.72.2";
      crxPath = builtins.fetchurl {
        name = "${id}.crx";
        url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
        sha256 = "sha256:0cz5fi9gnynja34cjv709a0nk0ma5vgax27zqfqpd3glw72cl16i";
      };
    };

    extensions = [ublock] ++ (map createChromiumExtension (builtins.attrValues (import ./chromium_ext.nix)));
  in {
    enable = true;
    package =
      pkgs.ungoogled-chromium;
    inherit extensions;
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    nativeMessagingHosts = [];
    # commandLineArgs = [];
  };
}
