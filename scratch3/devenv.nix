{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  languages.javascript.package = pkgs.nodejs_20; # not slim = includes npm

  pre-commit.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs = {
          actionlint.enable = true;
          yamlfmt = {
            enable = true;
            settings = {
              formatter = {
                retain_line_breaks_single = true;
              };
            };
          };
        };
      };
    };
    yamllint = {
      enable = true;
      settings.configData = ''
        extends: default
        rules:
          comments:
            min-spaces-from-content: 1 # allow Renovate's version tags
          document-start: disable
          line-length:
            max: 118
            level: warning
          truthy: disable # false positives with GHA
      '';
    };
  };
}
