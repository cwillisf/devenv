_: {
  languages = {
    go.enable = true;
  };

  pre-commit.hooks = {
    check-json.enable = true;
    check-yaml.enable = true;
    checkmake.enable = true;
    golangci-lint.enable = true;
    govet.enable = true;
    hadolint.enable = true;
    revive.enable = true;
    staticcheck.enable = true;
    yamllint = {
      enable = true;
      settings.configuration = ''
        extends: relaxed
        rules:
          line-length:
            max: 118
      '';
    };
  };
}
