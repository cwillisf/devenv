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
    flake-parts.lib.mkFlake { inherit inputs; } (
    let
      propsImport = path: props@{ shell-id }: (
        flake-parts.lib.importApply path props
      );
      devEnvImport = path: (
        flake-parts.lib.importApply path { inherit propsImport; }
      );
    in
    {
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      imports = [
        inputs.devenv.flakeModule
        (devEnvImport ./parts/env-scratch-jr.nix)

        # Define the default shell
        (propsImport ./parts/props-common.nix { shell-id = "default"; })
      ];
    }
  );
}
