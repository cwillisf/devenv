# Everything else lives in the shared modules imported from devenv.yaml.
{ inputs, ... }:
{
  # Android apps (scratch-android, scratchjr-private): --profile android
  profiles.android.module = {
    imports = [ "${inputs.shared}/android/devenv.nix" ];
  };
}
