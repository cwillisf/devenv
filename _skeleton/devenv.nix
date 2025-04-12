{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  # languages.rust.enable = true;
  pre-commit.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        # programs.rustfmt.enable = true;
      };
    };
  };
}
