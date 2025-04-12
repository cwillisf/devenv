{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  languages.rust.enable = true;

  pre-commit.hooks = {
    cargo-check.enable = true;
    check-toml.enable = true;
    clippy.enable = true;
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs.rustfmt.enable = true;
        programs.taplo.enable = true;
      };
    };
  };
}
