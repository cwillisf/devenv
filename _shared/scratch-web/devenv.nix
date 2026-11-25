{
  lib,
  pkgs,
  ...
}:
{
  treefmt = {
    enable = true;
    config.programs = {
      # as of 2025-08-15, Prettier supports:
      # JS/JSX/TS, Angular, Vue, Flow, CSS/Less/SCSS, HTML, Ember/Handlebars, JSON, GraphQL, Markdown, and YAML
      # prettier = {
      #   enable = true;
      #   settings = {
      #     editorconfig = true;
      #     embeddedLanguageFormatting = "auto";
      #     printWidth = 118;
      #     quoteProps = "consistent";
      #   };
      # };
      yamlfmt.enable = true;
    };

    config.settings.formatter = {
      # treefmt-nix doesn't support settings for actionlint, so this hooks up actionlint as a custom formatter
      "actionlint" = {
        command = lib.getExe pkgs.actionlint;
        options = [
          "-config-file"
          (toString (
            pkgs.writeText "actionlint.yaml" ''
              self-hosted-runner:
                labels:
                  - Linux-ARM64-runner-v2
            ''
          ))
        ];
        includes = [
          ".github/workflows/*.yaml"
          ".github/workflows/*.yml"
        ];
      };
    };
  };

  # actionlint is a custom formatter (not a programs.* entry), so expose it explicitly.
  packages = [
    pkgs.actionlint
    pkgs.chromedriver
    pkgs.fastly
    pkgs.sauce-connect
    pkgs.libuuid
    # pkgs.playwright-driver.browsers
    pkgs.ungoogled-chromium

    pkgs.cairo
    pkgs.pango
    pkgs.pixman
    pkgs.pkg-config
  ];

  env = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.libgbm # chrome-headless-shell
      pkgs.libuuid
    ];
    # PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
  };

  dotenv.enable = true;
}
