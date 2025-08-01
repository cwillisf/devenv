{ pkgs, inputs, ... }:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
in
{
  packages = [
    pkgs.sauce-connect
  ];

  dotenv.enable = true;

  languages.javascript.package = pkgs.nodejs_20; # not slim = includes npm

  git-hooks.hooks = {
    treefmt = {
      enable = true;
      package = treefmt-nix {
        programs = {
          actionlint.enable = true;
          yamlfmt = {
            enable = true;
            settings = {
              formatter = {
                retain_line_breaks_single = true;
                max_line_length = 118;
                eof_newline = true;
              };
            };
          };
        };
      };
    };
  };
}
