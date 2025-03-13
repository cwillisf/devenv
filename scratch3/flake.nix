{
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
        system:
        let
          pkgs = import nixpkgs { inherit config; };
          pkgs2 = import nixpkgs-unstable { inherit config; };
          playwright-browsers = pkgs2.playwright-driver.browsers;
        in
        rec {
          default =
            let
              pre-commit-install-devenv-hooks = (
                pkgs.writeScriptBin "pre-commit-install-devenv-hooks" default.config.pre-commit.installationScript
              );
            in
            devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  packages = [
                    pre-commit-install-devenv-hooks
                    pkgs.bashInteractive
                    pkgs2.chromedriver
                    pkgs.git
                    playwright-browsers
                    pkgs2.vscode.fhs
                  ];

                  enterShell = ''
                    export PLAYWRIGHT_BROWSERS_PATH="${playwright-browsers}"
                    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
                  '';

                  languages = {
                    javascript = {
                      enable = true;
                      npm.enable = true;
                    };
                    python.enable = true;
                    shell.enable = true;
                    typescript.enable = true;
                  };

                  pre-commit.hooks = {
                    check-added-large-files.enable = true;
                    check-case-conflicts.enable = true;
                    check-merge-conflicts.enable = true;
                    check-symlinks.enable = true;
                    check-toml.enable = true;
                    check-yaml.enable = true;
                    editorconfig-checker.enable = true;
                    ripsecrets.enable = true;
                    treefmt = {
                      #enable = true; # figure out a better way to handle treefmt.toml
                      settings.formatters = [ pkgs2.taplo ];
                    };
                    trufflehog.enable = true;
                  };
                }
              ];
            };
        }
      );
    };
}
