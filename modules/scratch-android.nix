{ pkgs, ... }:
{
  packages = [
    pkgs.unstable.chromedriver
    playwright.browsers
  ];

  enterShell = ''
    export PLAYWRIGHT_BROWSERS_PATH="${playwright.browsers}"
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  '';

  languages.android = {
    enable = true;
    platforms.version = [ "34" ];
    systemImageTypes = [ "google_apis_playstore" ];
    emulator.enable = true;
    android-studio.enable = true;
    # 2022.3.1 Patch 4 = 223.8836.35.2231.11090377
    # 2024.1.2 = 241.18034.62.2412.12266719
  };
}
