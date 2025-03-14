{ pkgs, ... }:
let
  inherit (pkgs.unstable) playwright;
in
{
  packages = [
    pkgs.unstable.chromedriver
    playwright.browsers
  ];

  enterShell = ''
    export PLAYWRIGHT_BROWSERS_PATH="${playwright.browsers}"
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  '';

  languages = {
    javascript = {
      enable = true;
      npm.enable = true;
    };
    python.enable = true;
    shell.enable = true;
    typescript.enable = true;
  };
}
