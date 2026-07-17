{
  pkgs,
  lib,
  config,
  ...
}: {
  programs = {
    chromium = {
      commandLineArgs = [];
      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];

      enable = true;
      extensions = [
        {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} # ublock-origin
        {id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # enhancer-for-youtube
      ];

      # extensions.*.crxPath = "";
      # extensions.*.id = "";
      # extensions.*.updateUrl = "";
      # extensions.*.version = "";
      nativeMessagingHosts = [];

      package =
        pkgs.ungoogled-chromium;
    };
  };
}
