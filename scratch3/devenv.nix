{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  packages = [
    pkgs.sauce-connect
  ];

  dotenv.enable = true;

  languages.javascript.package = pkgs.nodejs_20; # not slim = includes npm

  git-hooks.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs = {
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
              (builtins.toString (pkgs.writeText "actionlint.yaml" ''
                self-hosted-runner:
                  labels:
                    - Linux-ARM64-runner-v2
              ''))
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
