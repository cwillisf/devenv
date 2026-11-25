{
  pkgs,
  config,
  lib,
  ...
}:
let
  # Under the project root's .devenv/ rather than config.devenv.dotfile, which a
  # profile moves to .devenv/profiles/<name>; the chainer below needs one fixed
  # place to find any project's hooks.
  hookStateDir = "${config.devenv.root}/.devenv/git-hooks";
  hookDir = "${hookStateDir}/chain";
  prekDir = "${hookStateDir}/prek"; # prek hooks will go into a "hooks" subdir
  prekHookDir = "${prekDir}/hooks"; # subdir must be named "hooks" to make `prek install --git-dir` happy
  gitHookChainer = pkgs.writeShellScript "devenv-git-hook-chainer" ''
    set -e
    hook=$(basename "$0")
    # The GIT_CONFIG_* overrides below reach every repo git runs in while this
    # environment is loaded, not just this project. Long-lived processes such as
    # Claude Code keep the environment of their launch directory, so run the prek
    # hooks of whichever repo git is in: this project's in its own repo, another
    # devenv project's in that one (same layout), and none in a repo without them.
    toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
    prekHooks=
    if [ -n "$toplevel" ]; then
      prekHooks="$toplevel/.devenv/git-hooks/prek/hooks"
    fi
    if [ -n "$prekHooks" ] && [ -x "$prekHooks/$hook" ]; then
      "$prekHooks/$hook" "$@"
    fi
    # Find the repo's own hooks without the devenv GIT_CONFIG_* overrides, so that
    # tools like husky (which set core.hooksPath in repo config) are found.
    repoHooksPath=$(GIT_CONFIG_COUNT=0 git rev-parse --git-path hooks)
    if [ "$repoHooksPath" != "${hookDir}" ] && [ -x "$repoHooksPath/$hook" ]; then
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

  #claude.code = {
  #  enable = true;
  #  hooks.git-hooks-run = {
  #    matcher = "^(Edit|MultiEdit|Write)$";
  #    command = toString (
  #      pkgs.writeShellScript "claude-git-hooks-run" ''
  #        set -euo pipefail
  #        file=$(${lib.getExe pkgs.jq} -r '.tool_input.file_path // ""')
  #        [[ -z "$file" || "$file" == "null" ]] && exit 0
  #        root=$(${lib.getExe pkgs.git} -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
  #        cd "$root" && ${lib.getExe config.git-hooks.package} run -c "${config.devenv.root}/${config.git-hooks.configPath}" --files "$file"
  #      ''
  #    );
  #  };
  #};

  languages.shell.enable = true;

  packages = [
    pkgs.bashInteractive
    pkgs.gh
    pkgs.git
    pkgs.vscode
  ]
  # devenv's treefmt module puts only its wrapper on PATH; editors want the
  # formatters too, configured the same way.
  ++ lib.optionals config.treefmt.enable (lib.attrValues config.treefmt.config.build.programs);

  # Install hooks into a devenv-local directory so they don't clobber husky's .git/hooks/.
  # GIT_CONFIG_* overrides core.hooksPath at higher priority than repo config (e.g. set by husky),
  # and is automatically active only while inside the devenv shell.
  env = lib.mkIf config.git-hooks.enable {
    GIT_CONFIG_COUNT = "1";
    GIT_CONFIG_KEY_0 = "core.hooksPath";
    GIT_CONFIG_VALUE_0 = hookDir;
  };

  # Configs enable treefmt and pick formatters; these apply to all of them.
  treefmt.config.programs.yamlfmt.settings.formatter = {
    retain_line_breaks_single = true;
    eof_newline = true;
  };
  git-hooks.hooks.treefmt.enable = lib.mkDefault config.treefmt.enable;

  tasks = lib.mkMerge [
    (lib.mkIf config.treefmt.enable {
      # Format at commit time only, not over the whole tree on every shell entry.
      "devenv:treefmt:run".before = lib.mkForce [ ];
    })
    (lib.mkIf config.git-hooks.enable {
      # The chainer goes in even when the project isn't a git repo (e.g. ~/claude):
      # core.hooksPath points at ${hookDir} regardless, and without the chainer
      # other repos' own hooks would silently stop running.
      "devenv:git-hooks:install".exec = lib.mkForce ''
        stages="pre-commit pre-merge-commit prepare-commit-msg commit-msg post-commit pre-rebase post-checkout post-merge pre-push post-rewrite"
        mkdir -p "${hookDir}"
        for stage in $stages; do
          ln -sf "${gitHookChainer}" "${hookDir}/$stage"
        done
        if ! "${lib.getExe pkgs.git}" rev-parse --git-dir &> /dev/null; then
          echo 1>&2 "git-hooks: .git not found; installed the chainer only, skipping prek."
          exit 0
        fi
        echo "Installing git hooks into ${hookDir} which will chain with ${prekHookDir}..."
        mkdir -p "${prekHookDir}"
        for stage in $stages; do
          GIT_CONFIG_COUNT=0 "${lib.getExe pkgs.prek}" install --git-dir "${prekDir}" -f -c "${config.devenv.root}/${config.git-hooks.configPath}" -t "$stage"
        done
        echo "Installed git hooks into ${hookDir} which will chain with ${prekHookDir}."
      '';
    })
  ];

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
        "MD013" = false;
      };
    };
    mixed-line-endings.enable = true;
    ripsecrets.enable = false; # too many false positives, including `data:image/png;base64,...`
    shellcheck.enable = true;
    trim-trailing-whitespace.enable = true;
    #trufflehog.enable = true; # broken as of 2025-11-16
    typos = {
      enable = true;
      # Android translations (values-b+pt+BR/, values-es/, values-pt-rBR/): not English
      excludes = [ "/res/values-(b\\+[^/]+|[a-z]{2,3}(-r[A-Z]{2})?)/" ];
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
              level: warning
            truthy: disable # false positives with GHA
        '';
      };
    };
  };
}
