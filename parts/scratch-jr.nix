{ devEnvRoot, ... }:
{ inputs, ... }:
{
  perSystem = { config, self', inputs', pkgs, system, ... }:
  let
    pkgs-android-studio = (import inputs.scratch-jr-android-studio {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    });
  in
  {
    devenv.shells.ScratchJr = {
      devenv.root = devEnvRoot;

      name = "scratch-jr";

      packages = [
        pkgs-android-studio.android-studio-full
        pkgs.git
      ];
    };
  };
}
