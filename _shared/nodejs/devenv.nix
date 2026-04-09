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
      package =
        lib.mkDefault
          pkgs."nodejs${
            lib.optionalString (config.devenv-override.node-major != "") "_${config.devenv-override.node-major}"
          }";
    };

    git-hooks.hooks = {
      check-json = {
        enable = true;
        excludes = [ "tsconfig.*\\.json$" ];
      };
    };
  };
}
