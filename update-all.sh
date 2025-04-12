#!/usr/bin/env bash

for dir in */; do
  if [ -f "$dir/devenv.lock" ]; then
    (cd "$dir" && devenv update)
  fi
done
