# betterbird, from nixbuilds, for mail and calendars. the accounts are
# private, in accounts.email.accounts with thunderbird.enable
{
  lib,
  osConfig,
  pkgs,
  ...
}:

lib.modules.mkIf osConfig.dotnix.profiles.apps.enable {
  programs.thunderbird = {
    enable = true;
    package = pkgs.betterbird;

    profiles.main = {
      isDefault = true;
      withExternalGnupg = true;
      settings = {
        # stay on the account list, not a web page
        "mailnews.start_page.enabled" = false;
        "mail.shell.checkDefaultClient" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
      };
    };
  };
}
