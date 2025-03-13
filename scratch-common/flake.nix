{
  description = "Development environment that includes elements common to most or all Scratch Foundation projects";

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
    rec {
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
          pkgs2 = import nixpkgs-unstable { inherit config; };
        in
        rec {
          default =
            let
              pre-commit-install-devenv-hooks = pkgs.writeScriptBin "pre-commit-install-devenv-hooks" default.config.pre-commit.installationScript;
            in
            devenv.lib.mkShell {
              inherit inputs pkgs;
              # File types:
              # - *.json (various config files)
              # - *.json5 (Renovate)
              # - *.md (README.md)
              # - *.sh (various shell scripts)
              # - *.yml (GHA)
              modules = [
                {
                  packages = [
                    pre-commit-install-devenv-hooks
                    pkgs.bashInteractive
                    pkgs.git
                    pkgs2.vscode.fhs
                  ];

                  languages = {
                    shell.enable = true;
                  };

                  pre-commit.hooks = {
                    check-added-large-files.enable = true;
                    check-case-conflicts.enable = true;
                    check-json.enable = true;
                    check-merge-conflicts.enable = true;
                    check-symlinks.enable = true;
                    check-yaml.enable = true;
                    eclint.enable = true;
                    editorconfig-checker.enable = true;
                    markdownlint = {
                      enable = true;
                      settings.configuration = {
                        "MD013" = {
                          "line_length" = 118;
                        };
                      };
                    };
                    ripsecrets.enable = true;
                    trufflehog.enable = true;
                    typos.enable = true;
                    yamllint = {
                      enable = true;
                      settings.configuration = ''
                        extends: relaxed
                        rules:
                          line-length:
                            max: 118
                      '';
                    };
                  };
                }
              ];
            };
        }
      );
    };
}
