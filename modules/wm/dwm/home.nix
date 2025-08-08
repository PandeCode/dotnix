{
  config,
  dotutils,
  ...
}: let
  font = config.stylix.fonts.sansSerif.name;
  c = config.lib.stylix.colors;
in {
  imports = [../x/home.nix];

  dotnix.symlinkPairs = [
    ["~/dotnix/submodules/dwm-flexipatch/autostart.sh" "~/.local/share/dwm/autostart.sh"]
    ["~/dotnix/submodules/dwm-flexipatch/autostart_blocking.sh" "~/.local/share/dwm/autostart_blocking.sh"]
    ["~/dotnix/submodules/dwm-flexipatch/patch/layoutmenu.sh" "~/dotnix/bin/layoutmenu.sh"]
  ];

  xresources.properties =
    {"dwm.font" = font;}
    // (dotutils.mapAttrsWithKeyTransform (k: v: {
        name = "dwm.${k}";
        value = "#${v}";
      }) {
        # Normal (unfocused) windows
        normfgcolor = c.base05;
        normbgcolor = c.base00;
        normbordercolor = c.base02;
        normfloatcolor = c.base01;

        # Selected (focused) windows
        selfgcolor = c.base00;
        selbgcolor = c.base0D;
        selbordercolor = c.base0D;
        selfloatcolor = c.base0D;

        # Titlebar colors
        titlenormfgcolor = c.base04;
        titlenormbgcolor = c.base00;
        titlenormbordercolor = c.base02;
        titlenormfloatcolor = c.base02;

        titleselfgcolor = c.base00;
        titleselbgcolor = c.base0D;
        titleselbordercolor = c.base0D;
        titleselfloatcolor = c.base0D;

        # Tag colors (workspace indicators)
        tagsnormfgcolor = c.base04;
        tagsnormbgcolor = c.base00;
        tagsnormbordercolor = c.base01;
        tagsnormfloatcolor = c.base01;

        tagsselfgcolor = c.base00;
        tagsselbgcolor = c.base0A;
        tagsselbordercolor = c.base0A;
        tagsselfloatcolor = c.base0A;

        # Hidden windows
        hidnormfgcolor = c.base03;
        hidnormbgcolor = c.base00;
        hidselfgcolor = c.base00;
        hidselbgcolor = c.base0D;

        # Urgent window
        urgfgcolor = c.base00;
        urgbgcolor = c.base0F;
        urgbordercolor = c.base0F;
        urgfloatcolor = c.base0F;

        # Optional: Scratchpad support (if patch enabled)
        scratchnormfgcolor = c.base04;
        scratchnormbgcolor = c.base00;
        scratchnormbordercolor = c.base02;
        scratchnormfloatcolor = c.base01;

        scratchselfgcolor = c.base00;
        scratchselbgcolor = c.base0E;
        scratchselbordercolor = c.base0E;
        scratchselfloatcolor = c.base0E;

        # Optional: FlexWinTitle patch
        normTTBbgcolor = c.base00;
        normLTRbgcolor = c.base00;
        normMONObgcolor = c.base00;
        normGRIDbgcolor = c.base00;
        normGRD1bgcolor = c.base00;
        normGRD2bgcolor = c.base00;
        normGRDMbgcolor = c.base00;
        normHGRDbgcolor = c.base00;
        normDWDLbgcolor = c.base00;
        normSPRLbgcolor = c.base00;
        normfloatbgcolor = c.base01;

        actTTBbgcolor = c.base02;
        actLTRbgcolor = c.base02;
        actMONObgcolor = c.base02;
        actGRIDbgcolor = c.base02;
        actGRD1bgcolor = c.base02;
        actGRD2bgcolor = c.base02;
        actGRDMbgcolor = c.base02;
        actHGRDbgcolor = c.base02;
        actDWDLbgcolor = c.base02;
        actSPRLbgcolor = c.base02;
        actfloatbgcolor = c.base01;

        selTTBbgcolor = c.base0D;
        selLTRbgcolor = c.base0D;
        selMONObgcolor = c.base0D;
        selGRIDbgcolor = c.base0D;
        selGRD1bgcolor = c.base0D;
        selGRD2bgcolor = c.base0D;
        selGRDMbgcolor = c.base0D;
        selHGRDbgcolor = c.base0D;
        selDWDLbgcolor = c.base0D;
        selSPRLbgcolor = c.base0D;
        selfloatbgcolor = c.base0D;
      });
}
