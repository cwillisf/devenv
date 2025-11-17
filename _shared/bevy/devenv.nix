{
  pkgs,
  lib,
  ...
}:
let
  # See https://github.com/bevyengine/bevy/blob/latest/docs/linux_dependencies.md#nix
  # `bevy-libs` is taken from `buildInputs` and the extra `packages` below are taken from `nativeBuildInputs`
  bevy-libs = with pkgs; [
    udev
    alsa-lib
    vulkan-loader

    # To use the x11 feature
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr

    # To use the wayland feature
    libxkbcommon
    wayland
  ];
in
{
  env.LD_LIBRARY_PATH = lib.makeLibraryPath bevy-libs;

  packages =
    bevy-libs
    ++ (with pkgs; [
      pkg-config
    ]);
}
