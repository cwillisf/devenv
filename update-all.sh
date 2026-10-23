#!/usr/bin/env bash
set -e

success=()
failed=()
logdir="$(mktemp -d -t update-all.XXXXXX)"

for dir in */; do
  dir="${dir%/}"
  lockfile="$dir/devenv.lock"
  [ -f "$lockfile" ] || continue

  echo "==> $dir"
  log="$logdir/$dir.log"

  # Build the shell after updating so a broken update never gets committed.
  # A failed env keeps its last committed lockfile until upstream is fixed.
  if (cd "$dir" && devenv update && devenv shell -- true) > "$log" 2>&1; then
    success+=("$lockfile")
  else
    echo "    failed; reverting $lockfile (log: $log)"
    git checkout -- "$lockfile"
    failed+=("$dir")
  fi
done

# The `success` array contains files that updated and built. They're most
# likely modified, but it's possible that some or all are unchanged.
if (( ${#success[@]} )); then
  # Attempt the commit twice in case the first one runs pre-commit fixes.
  git commit -m './update-all.sh' "${success[@]}" || \
  git commit -m './update-all.sh' "${success[@]}" || \
  true
fi

if (( ${#failed[@]} )); then
  echo "Not updated (build failed): ${failed[*]}"
  echo "Logs: $logdir"
  exit 1
fi
