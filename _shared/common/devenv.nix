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

  languages.shell.enable = true;

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
    check-executables-have-shebangs.enable = true;
    check-json.enable = true;
    check-merge-conflicts.enable = true;
    check-symlinks.enable = true;
    detect-aws-credentials.enable = true;
    detect-private-keys.enable = true;
    editorconfig-checker.enable = true;
    end-of-file-fixer.enable = true;
    fix-byte-order-marker.enable = true;
    gitlint = {
      enable = true;
      # this hack is sad for at least two reasons:
      # - it'd be unnecessary if `gitlint.args` were inserted before `--msg-filename`
      # - it uses `gitlint` from `$PATH` which might not be the one installed by this hook
      #   (it could be an incompatible version or even some unrelated program of the same name)
      entry = "gitlint --staged --ignore body-is-missing --msg-filename";
    };
    html-tidy.enable = true;
    lychee = {
      enable = true;
      settings.configPath = toString (
        pkgs.writeText "lychee.toml" ''
          cache = true
          max_cache_age = "2d"
          exclude_path = ['package-lock.json$']
          exclude = ['\$%7B']
          exclude_all_private = true
        ''
      );
    };
    markdownlint = {
      enable = true;
      settings.configuration = {
        "MD013" = {
          "line_length" = 118;
        };
      };
    };
    mixed-line-endings.enable = true;
    ripsecrets.enable = true;
    shellcheck.enable = true;
    trim-trailing-whitespace.enable = true;
    #trufflehog.enable = true;
    typos = {
      enable = true;
      settings.ignored-words = [
        "Hashi" # HashiCorp
        "inferrable" # @typescript-eslint/no-inferrable-types
      ];
    };
  };
}
