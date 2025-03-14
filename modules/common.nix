{ config, pkgs, ... }:
let
  pre-commit-install-devenv-hooks = pkgs.writeScriptBin "pre-commit-install-devenv-hooks" config.pre-commit.installationScript;
in
{
  packages = [
    pre-commit-install-devenv-hooks
    pkgs.bashInteractive
    pkgs.git
    pkgs.unstable.vscode.fhs
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
