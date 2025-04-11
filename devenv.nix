{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs {
    programs = {
      deadnix.enable = true;
      nixfmt.enable = true;
      statix.enable = true;
    };
  };
in
{
  languages.nix.enable = true;
  pre-commit.hooks = {
    nil.enable = true;
    statix.enable = true;
    treefmt = {
      enable = true;
      package = treefmt-nix;
    };
  };
}
