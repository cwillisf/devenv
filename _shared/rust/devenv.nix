_:
{
  languages.rust.enable = true;

  pre-commit.hooks = {
    cargo-check.enable = true;
    check-toml.enable = true;
    clippy.enable = true;
  };
}
