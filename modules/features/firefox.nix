{ ... }:
{
  config.hmModules = [
    {
      programs.firefox = {
        enable = true;
        profiles.default = {
          name = "default";
          isDefault = true;
          settings = {
            "browser.startup.homepage"                              = "about:blank";
            "browser.newtabpage.enabled"                           = false;
            "browser.newtabpage.activity-stream.showSponsored"     = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "general.smoothScroll"                                 = true;
            "mousewheel.default.delta_multiplier_y"                = 200;
            "privacy.donottrackheader.enabled"                     = true;
            "privacy.trackingprotection.enabled"                   = true;
            "privacy.trackingprotection.socialtracking.enabled"    = true;
            "geo.enabled"                                          = false;
            "datareporting.healthreport.uploadEnabled"             = false;
            "datareporting.policy.dataSubmissionEnabled"           = false;
            "toolkit.telemetry.enabled"                            = false;
            "toolkit.telemetry.unified"                            = false;
            "browser.toolbars.bookmarks.visibility"                = "never";
            "browser.compactmode.show"                             = true;
            "browser.uidensity"                                    = 1;
            "gfx.webrender.all"                                    = true;
            "media.ffmpeg.vaapi.enabled"                           = true;
          };
        };
      };
    }
  ];
}
