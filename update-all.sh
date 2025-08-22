#!/usr/bin/env bash
set -e

success=()

for dir in */; do
  lockfile="$dir/devenv.lock"
  if [ -f "$lockfile" ]; then
    (cd "$dir" && devenv update) && success+=("$lockfile")
  fi
done

# The `success` array contains files for which `devenv update` did not error.
# They're most likely modified, but it's possible that some or all are unchanged.
if (( ${#success[@]} )); then
  git commit -m './update-all.sh' "${success[@]}"
fi
