{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  git-hooks.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs.yamlfmt = {
          enable = true;
          settings.formatter = {
            retain_line_breaks_single = true;
            max_line_length = 118;
            eof_newline = true;
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
