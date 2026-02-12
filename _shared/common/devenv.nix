{
  pkgs,
  config,
  ...
}:
let
  git-hooks-installation-script = pkgs.writeScriptBin "git-hooks-installation-script" (
    if config.git-hooks.enable then
      config.git-hooks.installationScript
    else
      "echo git-hooks.enable is false"
  );
in
{
  cachix.enable = true;
  cachix.pull = [
    "nix-community"
    "pre-commit-hooks"
  ];

  languages.shell.enable = true;

  packages = [
    git-hooks-installation-script
    pkgs.antigravity
    pkgs.bashInteractive
    pkgs.gh
    pkgs.git
    pkgs.vscode
  ];

  git-hooks.hooks = {
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-executables-have-shebangs.enable = true;
    check-json.enable = true;
    check-merge-conflicts.enable = true;
    check-symlinks.enable = true;
    detect-aws-credentials.enable = true;
    detect-private-keys.enable = true;
    #editorconfig-checker.enable = true; # broken for Markdown vs. Prettier
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
          exclude_path = ['package-lock.json$']
          exclude = ['\$%7B', '/postgresql:/@/', '@users\.noreply\.github\.com$']
          exclude_all_private = true
          hidden = true
          include_mail = true
          include_verbatim = true
          max_cache_age = "2d"
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
    #trufflehog.enable = true; # broken as of 2025-11-16
    typos = {
      enable = true;
      settings.ignored-words = [
        "Chararacters" # legacy misspelling in Konsole settings
        "Hashi" # HashiCorp
        "HASS"
        "inferrable" # @typescript-eslint/no-inferrable-types
        "substituters"
      ];
    };
    yamllint = {
      enable = true;
      verbose = true; # show warnings
      settings = {
        strict = false; # don't fail on warnings
        configData = ''
          extends: default
          rules:
            comments:
              min-spaces-from-content: 1 # allow Renovate's version tags
            document-start: disable
            line-length:
              max: 118
              level: warning
            truthy: disable # false positives with GHA
        '';
      };
    };
  };
}
