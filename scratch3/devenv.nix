{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  packages = [
    pkgs.chromedriver
    pkgs.fastly
    pkgs.sauce-connect
    pkgs.libuuid
    # pkgs.playwright-driver.browsers
    pkgs.ungoogled-chromium
  ];

  env = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.libgbm # chrome-headless-shell
      pkgs.libuuid
    ];
    # PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
  };

  dotenv.enable = true;

  languages.java.enable = true; # for legacy Closure compiler

  git-hooks.enable = false; # stop fighting with husky
  git-hooks.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs = {
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
          yamlfmt = {
            enable = true;
            settings = {
              formatter = {
                retain_line_breaks_single = true;
                max_line_length = 118;
                eof_newline = true;
              };
            };
          };
        };

        settings.formatter = {
          # treefmt-nix doesn't support settings for actionlint, so this hooks up actionlint as a custom formatter
          "actionlint" = {
            command = "${pkgs.actionlint}/bin/actionlint";
            options = [
              "-config-file"
              (builtins.toString (
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
    };
  };
}
