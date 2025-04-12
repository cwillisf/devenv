{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  pre-commit.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs.rustfmt.enable = true;
        programs.taplo.enable = true;
      };
    };
  };
}
