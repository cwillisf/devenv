{
  description = "Development environment for Scratch 3 (scratch-editor)";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      devenv,
      systems,
      ...
    }@inputs:
    let
      config = {
        allowUnfree = true;
      };
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      checks = forEachSystem (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run { src = ./.; };
      });

      formatter = forEachSystem (system: nixpkgs-unstable.legacyPackages.${system}.nixfmt-rfc-style);

      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
        devenv-test = self.devShells.${system}.default.config.test;
      });

      devShells = forEachSystem (
        _system:
        let
          pkgs = import nixpkgs { inherit config; };
          pkgs-unstable = import nixpkgs-unstable { inherit config; };
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs;

            # mkShell doesn't have `specialArgs`
            pkgs = pkgs // {
              unstable = pkgs-unstable;
            };

            modules = [
              ../../modules/common.nix
              ../../modules/scratch-common.nix
              ../../modules/scratch-android.nix
              ../../modules/scratchjr.nix
            ];
          };
        }
      );
    };
}
