#!/bin/bash
# Git snapshot of the SilverBullet space. Run by snapshot-watch.sh, or by
# hand, as the space owner:
#   ./snapshot.sh /srv/silverbullet/space
#
# This is what makes an agent's (or your own) overwrite recoverable. Commits
# only when something changed, so quiet days leave no empty commits.
set -euo pipefail

cd "${1:?space directory}"

# A manual run can coincide with the watcher's. Without the lock the second
# one dies on git's index.lock and reports a failure that isn't one.
exec 9>.git/snapshot.lock
flock 9

# gc.autoDetach=false: a detached `gc --auto` inherits fd 9 and would hold the
# lock after this script exits, stalling the next snapshot for no reason.
git_c=(git -c user.name=silverbullet-snapshot -c user.email=snapshot@localhost -c gc.autoDetach=false)

"${git_c[@]}" add -A
if "${git_c[@]}" diff --cached --quiet --exit-code; then
  exit 0
fi
# The diff records what changed; the message only needs to record when.
"${git_c[@]}" commit -q -m "snapshot $(date -Is)"
