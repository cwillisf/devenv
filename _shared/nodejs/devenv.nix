_: {
  languages.javascript.enable = true;
  # npm is excluded from "slim" versions of nodejs but included in the regular ones
  #languages.javascript.package = pkgs.nodejs-slim; # latest slim (default)
  #languages.javascript.package = pkgs.nodejs; # latest regular
  #languages.javascript.package = pkgs.nodejs_20; # # specific version
  #languages.javascript.package = pkgs.nodejs_20-slim; # specific version slim
  #languages.npm.enable = true;

  pre-commit.hooks = {
    check-json.enable = true;
  };
}
