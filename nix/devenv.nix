{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  languages.nix.enable = true;
  pre-commit.hooks = {
    nil.enable = true;
    pre-commit-hook-ensure-sops.enable = true; # pre-commit hook to ensure that files that should be encrypted with sops are
    statix.enable = true;
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          statix.enable = true;
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
      settings.configData = "{extends: default, rules: {document-start: disable}}";
    };
  };
}
