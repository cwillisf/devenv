{ shell-id, ... }:
{ inputs, ... }:
{
  perSystem = { config, self', inputs', lib, pkgs, pkgs-unstable, system, ... }:
  let
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "code"
          "vscode"
        ];
    };
  in
  {
    devenv.shells.${shell-id} = {
      devenv.root = let
          devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
        in
          lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

      packages = [
        pkgs.bashInteractive
        pkgs.git
        pkgs-unstable.vscode.fhs
      ];

      pre-commit.hooks = {
        check-added-large-files.enable = true;
        check-case-conflicts.enable = true;
        check-merge-conflicts.enable = true;
        check-symlinks.enable = true;
        editorconfig-checker.enable = true;
        ripsecrets.enable = true;
        #treefmt.enable = true; # TODO
        trufflehog.enable = true;
      };
    };
  };
}
