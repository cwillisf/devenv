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

  env.CARGO_PROFILE_DEV_BUILD_OVERRIDE_DEBUG = "true";

  git-hooks.hooks = {
    cargo-check.enable = true;
    check-toml.enable = true;
    clippy.enable = true;
  };
}
