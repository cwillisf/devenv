{
  config,
  pkgs,
  lib,
  ...
}:
let
  # devenv's own android module computes "latest" (for platformTools/emulator)
  # via `lib.last (builtins.sort builtins.lessThan ...)`, i.e. plain
  # lexicographic string comparison. That's wrong for any package whose
  # version numbers cross a digit-count boundary: for cmdline-tools
  # (versions "1.0".."22.0"), it picks "9.0" - older than the "11.0" default,
  # and not even the true latest. Compare "major.minor" numerically instead.
  # Excludes -rcN/-beta-style prereleases (their trailing text makes the
  # exact-match regex fail).
  latestStableVersion =
    package:
    let
      repoJson = builtins.fromJSON (
        builtins.readFile "${toString pkgs.path}/pkgs/development/mobile/androidenv/repo.json"
      );
      versions = builtins.attrNames repoJson.packages.${package};
      stable = builtins.filter (v: builtins.match "[0-9]+\\.[0-9]+" v != null) versions;
      key =
        v:
        (lib.toInt (builtins.elemAt (lib.splitString "." v) 0)) * 1000
        + (lib.toInt (builtins.elemAt (lib.splitString "." v) 1));
    in
    lib.last (lib.sort (a: b: key a < key b) stable);
in
{
  # Sync with https://developer.android.com/build/jdks
  languages.java.jdk.package = pkgs.jdk17;

  android = {
    enable = true;
    abis = [ "x86_64" ];
    buildTools.version = [
      "34.0.0"
      "35.0.0"
    ];
    # 35 added, and google_apis_playstore_tablet added alongside the plain
    # google_apis_playstore type, for tablet-shaped AVDs (e.g. "Pixel
    # Tablet"). This SDK lives in the read-only Nix store, so anything an AVD
    # needs has to be declared here rather than installed through Android
    # Studio's AVD wizard - that fails with "Failed to read or create install
    # properties file" since it can't write into the store.
    platforms.version = [
      "32"
      "34"
      "35"
      "36"
    ];
    systemImageTypes = [
      "google_apis_playstore"
      "google_apis_playstore_tablet"
    ];
    # A pinned version here (we were stuck on the default 11.0) ships a
    # stale sdklib device catalog: Studio's AVD wizard offers device
    # profiles (Pixel Tablet, Medium Tablet, etc) that are bundled with the
    # IDE itself, writes the chosen device's id into the AVD's config.ini,
    # and then avdmanager - reading its own, older, cmdline-tools-bundled
    # devices.xml - doesn't recognize that id and fails with "Unknown
    # Error". cmdline-tools is pure SDK-manager tooling with no bearing on
    # the actual build output, so tracking "latest" here is low-risk and
    # keeps this from going stale again on a future devenv/nixpkgs update.
    cmdLineTools.version = latestStableVersion "cmdline-tools";
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

    # devenv's own android module prepends build-tools/lib64 and the NDK's
    # LLVM toolchain lib dir onto LD_LIBRARY_PATH (for aapt2, per its own
    # comment above). Verified aapt2 runs identically without them, but they
    # shadow the standalone `emulator` package's own (newer) libc++, which
    # crashes on launch with "undefined symbol" (an abseil/libc++ ABI
    # mismatch) - the actual cause of Android Studio's AVD "Unknown Error".
    # Strip them back out here, after devenv's module has already run.
    export LD_LIBRARY_PATH="$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v -E '/(build-tools/[^/]+/lib64|ndk(-bundle)?/([^/]+/)?toolchains/llvm/prebuilt/linux-x86_64/lib)/?$' | paste -sd: -)"
  '';
}
