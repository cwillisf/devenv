{
  pkgs,
  config,
  lib,
  ...
}:
let
  hookDir = "${config.devenv.root}/.devenv/git-hooks";
  prekDir = "${config.devenv.root}/.devenv/prek"; # prek hooks will go into a "hooks" subdir
  prekHookDir = "${prekDir}/hooks"; # subdir must be named "hooks" to make `prek install --git-dir` happy
  gitHookChainer = pkgs.writeShellScript "devenv-git-hook-chainer" ''
    set -e
    hook=$(basename "$0")
    if [ -x "${prekHookDir}/$hook" ]; then
      "${prekHookDir}/$hook" "$@"
    fi
    # Read the repo's core.hooksPath without the devenv GIT_CONFIG_* overrides,
    # so that tools like husky (which set core.hooksPath in repo config) are found.
    repoHooksPath=$(GIT_CONFIG_COUNT=0 git config core.hooksPath 2>/dev/null || echo ".git/hooks")
    if [ -x "$repoHooksPath/$hook" ]; then
      "$repoHooksPath/$hook" "$@"
    fi
  '';
in
{
  cachix.enable = true;
  cachix.pull = [
    "nix-community"
    "pre-commit-hooks"
  ];

  claude.code = {
    enable = true;
    mcpServers = {
      devenv = {
        type = "stdio";
        command = "devenv";
        args = [ "mcp" ];
        env = {
          DEVENV_ROOT = config.devenv.root;
        };
      };
      playwright = {
        type = "stdio";
        command = "npx";
        args = [ "@playwright/mcp@latest" ];
      };
    };
  };

  languages.shell.enable = true;

  packages = [
    pkgs.antigravity
    pkgs.bashInteractive
    pkgs.gh
    pkgs.git
    pkgs.vscode
  ];

  # Install hooks into a devenv-local directory so they don't clobber husky's .git/hooks/.
  # GIT_CONFIG_* overrides core.hooksPath at higher priority than repo config (e.g. set by husky),
  # and is automatically active only while inside the devenv shell.
  env = lib.mkIf config.git-hooks.enable {
    GIT_CONFIG_COUNT = "1";
    GIT_CONFIG_KEY_0 = "core.hooksPath";
    GIT_CONFIG_VALUE_0 = hookDir;
  };

  tasks = lib.mkIf config.git-hooks.enable {
    "devenv:git-hooks:install".exec = lib.mkForce ''
      if ! "${lib.getExe pkgs.git}" rev-parse --git-dir &> /dev/null; then
        echo 1>&2 "WARNING: git-hooks: .git not found; skipping hook installation."
        exit 0
      fi
      echo "Installing git hooks into ${hookDir} which will chain with ${prekHookDir}..."
      mkdir -p "${hookDir}"
      mkdir -p "${prekHookDir}"
      for stage in pre-commit pre-merge-commit prepare-commit-msg commit-msg post-commit pre-rebase post-checkout post-merge pre-push post-rewrite; do
        ln -sf "${gitHookChainer}" "${hookDir}/$stage"
        GIT_CONFIG_COUNT=0 "${lib.getExe pkgs.prek}" install --git-dir "${prekDir}" -f -c "${config.devenv.root}/${config.git-hooks.configPath}" -t "$stage"
      done
      echo "Installed git hooks into ${hookDir} which will chain with ${prekHookDir}."
    '';
  };

  git-hooks.hooks = {
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-executables-have-shebangs.enable = true;
    check-json = {
      enable = true;
      excludes = [ "tsconfig.*\\.json$" ];
    };
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
    ripsecrets.enable = false; # too many false positives, including `data:image/png;base64,...`
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
