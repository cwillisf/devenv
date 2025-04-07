# Examples of Devenv Setups

The commands used to create each example:

```sh
(cd devenv-init && devenv init)
(cd flake-standard && nix flake init --template github:cachix/devenv)
(cd flake-parts && nix flake init --template github:cachix/devenv#flake-parts)
```
