{ pkgs, inputs, ... }:
let
  treefmt = import "${inputs.shared}/treefmt.nix" { inherit pkgs inputs; } {
    programs.rustfmt.enable = true;
    programs.taplo.enable = true;
  };
in
{
  inherit (treefmt) packages;

  git-hooks.hooks = {
    treefmt = {
      enable = true;
      package = treefmt.wrapper;
    };
  };
}
