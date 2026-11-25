_: {
  languages.nix.enable = true;

  treefmt = {
    enable = true;
    config.programs = {
      deadnix.enable = true;
      nixfmt.enable = true;
      statix.enable = true;
      yamlfmt.enable = true;
    };
  };

  git-hooks.hooks = {
    nil.enable = true;
    pre-commit-hook-ensure-sops.enable = true; # pre-commit hook to ensure that files that should be encrypted with sops are
    statix.enable = true;
  };
}
