{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  treefmt = import "${inputs.shared}/treefmt.nix" { inherit pkgs inputs; } {
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
in
{
  # actionlint is a custom formatter (not a programs.* entry), so expose it explicitly.
  packages = [ pkgs.actionlint ] ++ treefmt.packages;

  git-hooks.hooks = {
    treefmt = {
      enable = true;
      package = treefmt.wrapper;
    };
  };
}
