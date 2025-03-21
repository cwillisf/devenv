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

  perSystem = { config, self', inputs', lib, pkgs, system, ... }:
  {
    # This overrides `pkgs` for ALL modules.
    # devenv allows overriding android-studio.package but does not currently allow overriding the SDK package
    # so freezing `pkgs` seems to be the only way to lock everything
    _module.args.pkgs = import inputs.nixpkgs-scratch-jr {
      inherit system;
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "android-sdk-cmdline-tools"
            "android-sdk-tools"
            "android-studio-stable"
          ];
      };
    };

    devenv.shells.${props.shell-id} = {
      android = {
        enable = true;
        platforms.version = [ "34" ];
        systemImageTypes = [ "google_apis_playstore" ];
        emulator.enable = true;
        android-studio.enable = true;
      };

      languages = {
        javascript = {
          enable = true;
          npm.enable = true;
        };
        python.enable = true;
        shell.enable = true;
      };
    };
  };
}
