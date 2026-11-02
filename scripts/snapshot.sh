#!/bin/bash
# Hourly git snapshot of the SilverBullet space. Run as the space owner, e.g.
#   17 * * * * /path/to/snapshot.sh /srv/silverbullet/space
#
# This is what makes an agent's (or your own) overwrite recoverable. Commits
# only when something changed, so quiet hours leave no empty commits.
set -euo pipefail

cd "${1:?space directory}"

git_c=(git -c user.name=silverbullet-snapshot -c user.email=snapshot@localhost)

"${git_c[@]}" add -A
if "${git_c[@]}" diff --cached --quiet --exit-code; then
  exit 0
fi
# The diff records what changed; the message only needs to record when.
"${git_c[@]}" commit -q -m "snapshot $(date -Is)"
