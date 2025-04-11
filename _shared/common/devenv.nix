{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "code"
        "vscode"
      ];
  };
  pre-commit-install-devenv-hooks = pkgs.writeScriptBin "pre-commit-install-devenv-hooks" config.pre-commit.installationScript;
in
{
  cachix.enable = true;
  cachix.pull = [
    "nix-community"
    "pre-commit-hooks"
  ];

  packages = [
    pre-commit-install-devenv-hooks
    pkgs.bashInteractive
    pkgs.gh
    pkgs.git
    pkgs-unstable.vscode-fhs
  ];

  pre-commit.hooks = {
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    check-symlinks.enable = true;
    editorconfig-checker.enable = true;
    markdownlint = {
      enable = true;
      settings.configuration = {
        "MD013" = {
          "line_length" = 118;
        };
      };
    };
    ripsecrets.enable = true;
    trufflehog.enable = true;
    typos.enable = true;
  };
}
