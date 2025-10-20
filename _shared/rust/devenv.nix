_: {
  languages.rust = {
    enable = true;
    channel = "stable";
    components = [
      # Defaults
      "rustc"
      "cargo"
      "clippy"
      "rustfmt"
      "rust-analyzer"

      # Extras
      "rust-src"
    ];
  };

  git-hooks.hooks = {
    cargo-check.enable = true;
    check-toml.enable = true;
    clippy.enable = true;
  };
}
