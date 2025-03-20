{
  description = "Description for the project";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    scratch-jr-android-studio.url = "github:nixos/nixpkgs?ref=959f3eb7862c0bd66cc953a8f199f2577e116c2a";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, devenv-root, nixpkgs, ... }:
    let
      devEnvRoot = let
          devenvRootFileContent = builtins.readFile devenv-root.outPath;
        in
          nixpkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;
      devEnvImport = path: (flake-parts.lib.importApply path { inherit devEnvRoot; });
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      imports = [
        inputs.devenv.flakeModule
        (devEnvImport ./parts/scratch-jr.nix)
      ];

      perSystem = { config, self', inputs', lib, pkgs, pkgs-unstable, system, ... }:
      {
        _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfreePredicate = pkg:
            builtins.elem (lib.getName pkg) [
              "code"
              "vscode"
            ];
        };

        # Default shell is configured for working on this flake
        devenv.shells.default = {
          devenv.root = devEnvRoot;
          packages = [
            pkgs.bashInteractive
            pkgs.git
            pkgs-unstable.vscode.fhs
          ];
        };

      };
    };
}
