{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  languages.nix.enable = true;
  pre-commit.hooks = {
    nil.enable = true;
    statix.enable = true;
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          statix.enable = true;
        };
      };
    };
  };
}
