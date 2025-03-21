{ propsImport, ... }:
{ inputs, ... }:
let
  props = {
    shell-id = "scratch-jr";
  };
in
{
  imports = [
    (propsImport ./props-common.nix props)
  ];

  perSystem = { config, self', inputs', pkgs, system, ... }:
  let
    pkgs-android-studio = import inputs.scratch-jr-android-studio {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
  in
  {
    devenv.shells.scratch-jr = {
      packages = [
        pkgs-android-studio.android-studio-full
        pkgs.nodejs_20
      ];
    };
  };
}
