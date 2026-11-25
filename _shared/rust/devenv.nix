_: {
  languages.rust = {
    enable = true;
    #channel = "stable";
    components = [
      # Defaults
      "rustc"
      "cargo"
      "clippy"
      "rustfmt"
      "rust-analyzer"

      # Extras
      #"rust-src"
    ];
  };

  env.CARGO_PROFILE_DEV_BUILD_OVERRIDE_DEBUG = "true";

  treefmt = {
    enable = true;
    config.programs = {
      rustfmt.enable = true;
      taplo.enable = true;
    };
  };

  git-hooks.hooks = {
    # clippy runs a full `cargo check` itself, so a separate cargo-check hook
    # would only compile everything twice.
    check-toml.enable = true;
    clippy.enable = true;
  };
}
