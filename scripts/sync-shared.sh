#!/usr/bin/env bash
# The Agent Skills format makes every skill self-contained: a skill cannot read a file
# that lives outside its own directory, because installers copy the directory alone.
# Four references are shared by several skills, so each skill carries its own copy and
# shared/ holds the canonical one. This script copies canonical -> skills, and with
# --check reports copies that have drifted instead of overwriting them.
set -euo pipefail
cd "$(dirname "$0")/.."
check=0; [ "${1:-}" = "--check" ] && check=1
drift=0
for canon in shared/*.md; do
  name=$(basename "$canon")
  for copy in */references/"$name"; do
    [ -e "$copy" ] || continue
    if ! cmp -s "$canon" "$copy"; then
      if [ $check -eq 1 ]; then echo "DRIFT  $copy differs from $canon"; drift=1
      else cp "$canon" "$copy"; echo "synced $copy"; fi
    fi
  done
done
[ $check -eq 1 ] && { [ $drift -eq 0 ] && echo "shared references identical in every skill" || exit 1; }
exit 0
