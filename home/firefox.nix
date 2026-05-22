# Firefox browser configuration.
# Home Manager manages Firefox profiles declaratively, including settings
# and extensions. Settings here override about:config values.
{ ... }:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      name = "default";
      isDefault = true;

      settings = {
        # New tab / startup
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        # Scrolling
        "general.smoothScroll" = true;
        "mousewheel.default.delta_multiplier_y" = 200;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "geo.enabled" = false;

        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;

        # UI
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # compact density

        # Hardware acceleration (important in VMs — disable if you see glitches)
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };

      # Extensions: install uBlock Origin manually from addons.mozilla.org
      # To manage extensions declaratively in the future, add the NUR flake input
      # and use: extensions.packages = [ pkgs.nur.repos.rycee.firefox-addons.ublock-origin ];
    };
  };
}
