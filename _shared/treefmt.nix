# Shared treefmt helper.
#
# Given a treefmt-nix module config, returns:
#   - wrapper:  the configured `treefmt` binary — use as the git-hook package.
#   - packages: the wrapper plus every *enabled* formatter program, for adding
#               to `packages` so editors/IDEs (and the CLI) find the same tools
#               the hook uses, configured the same way.
#
# Only `programs.*` formatters are auto-included in `packages`; a custom
# `settings.formatter.<name>` (e.g. actionlint wired up by hand) is not a
# package, so add its tool to `packages` explicitly.
#
# Usage (in a devenv.nix):
#   let
#     treefmt = import "${inputs.shared}/treefmt.nix" { inherit pkgs inputs; } {
#       programs.rustfmt.enable = true;
#       programs.taplo.enable = true;
#     };
#   in {
#     packages = [ ... ] ++ treefmt.packages;
#     git-hooks.hooks.treefmt = {
#       enable = true;
#       package = treefmt.wrapper;
#     };
#   }
{ pkgs, inputs }:
config:
let
  mod = (import inputs.treefmt-nix).evalModule pkgs config;
in
{
  inherit (mod.config.build) wrapper;
  # Mirrors treefmt-nix's own build.devShell composition.
  packages = [ mod.config.build.wrapper ] ++ pkgs.lib.attrValues mod.config.build.programs;
}
