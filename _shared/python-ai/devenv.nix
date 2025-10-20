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
    micromamba
    pkg-config
    stdenv.cc.cc.lib
  ];
in
{
  languages.python = {
    enable = true;
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
