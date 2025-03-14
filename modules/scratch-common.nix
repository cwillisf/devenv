_: {
  languages = {
    shell.enable = true;
  };

  pre-commit.hooks = {
    check-json.enable = true;
    check-yaml.enable = true;
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
