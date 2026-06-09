{ pkgs, inputs, ... }:
let
  treefmt = import "${inputs.shared}/treefmt.nix" { inherit pkgs inputs; } {
    programs = {
      deadnix.enable = true;
      nixfmt.enable = true;
      statix.enable = true;
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
  };
in
{
  languages.nix.enable = true;

  inherit (treefmt) packages;

  git-hooks.hooks = {
    nil.enable = true;
    pre-commit-hook-ensure-sops.enable = true; # pre-commit hook to ensure that files that should be encrypted with sops are
    statix.enable = true;
    treefmt = {
      enable = true;
      package = treefmt.wrapper;
    };
  };
}
