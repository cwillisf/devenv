{ config, ... }:
{
  android = {
    enable = true;
    abis = [ "x86_64" ];
    emulator.enable = true;
    systemImages.enable = true;
    android-studio.enable = true;
  };

  # Override devenv's default of $(pwd)/.android so that Android user data
  # (AVDs, caches) doesn't pollute the project directory.
  # Using enterShell because the android module sets ANDROID_USER_HOME
  # in a shell hook that runs after env vars are exported.
  enterShell = ''
    export ANDROID_USER_HOME="${config.devenv.dotfile}/.android"
    export ANDROID_AVD_HOME="$ANDROID_USER_HOME/avd"
    mkdir -p "$ANDROID_USER_HOME" "$ANDROID_AVD_HOME"
  '';
}
