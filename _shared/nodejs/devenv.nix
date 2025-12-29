{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.devenv-override.node-major = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Major version of Node.js to use, e.g. '20' for Node.js 20.x";
  };

  config = {
    languages.javascript = {
      enable = true;
      # Based on the documentation, I'd expect that
      # - setting `npm.enable` to true and
      # - using the `-slim` package
      # would result in installing the latest `npm` even for older versions of Node.
      # Instead, the result seems identical to setting `npm.enable` to false and using the non-slim package.
      npm.enable = true;
      package =
        lib.mkDefault
          pkgs."nodejs-slim${
            lib.optionalString (config.devenv-override.node-major != "") "_${config.devenv-override.node-major}"
          }";
    };

    git-hooks.hooks = {
      check-json.enable = true;
    };
  };
}
