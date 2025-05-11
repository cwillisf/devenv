{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  treefmt-nix = (import inputs.treefmt-nix).mkWrapper pkgs;
  python-libs = with pkgs; [
    cudaPackages.cudnn
    cudaPackages.cuda_cudart
    cudatoolkit
    glib
    libGL
    pkg-config
    stdenv.cc.cc.lib
  ];
in
{
  languages.python = {
    enable = true;
    venv.enable = true;
    libraries = python-libs;
  };

  env = {
    CUDA_HOME = "${pkgs.cudatoolkit}";
    CUDA_PATH = "${pkgs.cudatoolkit}";
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      "/run/opengl-driver"
      pkgs.cudatoolkit
      pkgs.cudaPackages.cudnn
      pkgs.stdenv.cc.cc
    ];
    LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.cudatoolkit
    ];
  };

  packages = python-libs;

  pre-commit.hooks = {
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
              };
            };
          };
        };
      };
    };
    yamllint = {
      enable = true;
      settings.configData = "{extends: default, rules: {document-start: disable}}";
    };
  };
}
