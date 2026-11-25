{
  config,
  lib,
  pkgs,
  ...
}:
let
  node = config.languages.javascript.package;
  major = lib.versions.major node.version;

  # node, npm and npx refuse to run in a repo whose .nvmrc asks for a different
  # major version, such as a checkout nested under another project's .envrc.
  # Only the .nvmrc at the git toplevel counts, since published packages in
  # node_modules sometimes ship their own. A passing check is exported so child
  # processes skip it.
  guard =
    bin:
    pkgs.writeShellScriptBin bin ''
      if [ -z "''${DEVENV_IGNORE_NVMRC:-}" ] && [ -z "''${_DEVENV_NVMRC_OK:-}" ] &&
        top=$(${lib.getExe pkgs.git} rev-parse --show-toplevel 2>/dev/null) && [ -r "$top/.nvmrc" ]; then
        want=$(${lib.getExe pkgs.gnused} -E -n '1s/^[[:space:]]*v?([0-9]+).*/\1/p' "$top/.nvmrc")
        if [ -n "$want" ] && [ "$want" != ${major} ]; then
          echo "${bin}: $top/.nvmrc asks for Node $want, but this environment has Node ${major}." >&2
          echo "Give the repo its own environment:" >&2
          echo "  echo 'source ~/devenv/_shared/envrc ''${DEVENV_CONFIG_NAME:-<config>}' > '$top/.envrc' && direnv allow '$top'" >&2
          echo "Or run anyway with DEVENV_IGNORE_NVMRC=1." >&2
          exit 1
        fi
      fi
      export _DEVENV_NVMRC_OK=1
      exec ${node}/bin/${bin} "$@"
    '';
in
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

    # hiPrio so these win over the same names from the nodejs package.
    packages = map (bin: lib.hiPrio (guard bin)) [
      "node"
      "npm"
      "npx"
    ];
  };
}
