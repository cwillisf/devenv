{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs {
    programs.rustfmt.enable = true;
  };
in {
  pre-commit.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix;
    };
  };
}
