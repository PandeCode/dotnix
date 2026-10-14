# a search of every dotnix.* option, with nuschtos search: the system side
# from one evaluated machine's options, the home side from modules/home on its
# own. nixbuilds publishes its packages the same way. baseHref is where it is
# served from: / locally, /dotnix/ on github pages
{
  pkgs,
  inputs,
  options,
  self,
  baseHref ? "/",
}:

let
  json =
    opts:
    (pkgs.nixosOptionsDoc {
      options = opts;
      warningsAreErrors = false;
    }).optionsJSON
    + /share/doc/nixos/options.json;

  # home-manager.users only knows its modules once a user's config is read,
  # so these are evaluated apart, the way checks.nix tries drop-in modules
  home =
    (import "${inputs.home-manager}/modules" {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      configuration = {
        imports = [ "${self}/modules/home" ];
        home = {
          username = "user";
          homeDirectory = "/home/user";
          stateVersion = "26.05";
        };
      };
    }).options;

  inherit (pkgs.stdenv.hostPlatform) system;

  urlPrefix = "https://github.com/PandeCode/dotnix/blob/main/";
in

inputs.search.packages.${system}.mkMultiSearch {
  title = "dotnix";
  inherit baseHref;
  # github pages has no fallback to index.html for other paths
  hashLocation = true;
  scopes = [
    {
      name = "system";
      optionsJSON = json { inherit (options) dotnix; };
      inherit urlPrefix;
    }
    {
      name = "home";
      optionsJSON = json { inherit (home) dotnix; };
      inherit urlPrefix;
    }
  ];
}
