#!/bin/bash
# Commit the SilverBullet space when it changes. Needs inotify-tools.
#   ./snapshot-watch.sh /srv/silverbullet/space [quiet_seconds] [max_delay_seconds]
#
# Meant to run under systemd (silverbullet-snapshot-watch.service). A timer
# would lose any version overwritten between ticks -- exactly the case that
# matters when the agent rewrites a page you edited minutes earlier.
#
# Debounced, because SilverBullet saves continually while you type: it commits
# after QUIET seconds without a change, and at least every MAX_DELAY seconds
# during continuous editing.
set -euo pipefail

SPACE="${1:?space directory}"
QUIET="${2:-60}"
MAX_DELAY="${3:-600}"
SNAPSHOT="$(dirname "$(readlink -f "$0")")/snapshot.sh"

pending=0
pending_since=0

# A failed commit must not kill the watcher: the change is still on disk, and
# the next commit's `git add -A` picks it up.
snapshot() {
  "$SNAPSHOT" "$SPACE" || echo "WARNING: snapshot failed; will retry on the next change" >&2
  pending=0
}

# .git is excluded or every commit would trigger the next one; _plug/ is
# downloaded plug code that git ignores anyway. -r adds watches for folders
# created later.
#
# stderr is merged in so the loop below can see "Watches established."; any
# other diagnostic just reads as an event, which costs at most one no-op commit.
exec 3< <(inotifywait -m -r \
  -e close_write -e moved_to -e moved_from -e delete -e create \
  --exclude '/(\.git|_plug)(/|$)' --format '%w%f' "$SPACE" 2>&1)

# Snapshot only once the watches exist, so nothing can change unseen between
# the two. This commits anything changed while the watcher was down, which --
# with every commit taking the whole space -- is why no backup timer is needed.
while read -r -u 3 line; do
  [[ "$line" == "Watches established." ]] && break
done
snapshot

while true; do
  # rc 0: an event. rc > 128: QUIET seconds passed with none. Anything else is
  # EOF -- inotifywait died -- so exit and let systemd restart the whole loop.
  read -r -t "$QUIET" -u 3 _ && rc=0 || rc=$?

  if (( rc == 0 )); then
    if (( ! pending )); then
      pending=1
      pending_since=$SECONDS
    fi
    # Continuous editing never goes quiet; checkpoint it anyway.
    if (( SECONDS - pending_since >= MAX_DELAY )); then
      snapshot
    fi
  elif (( rc > 128 )); then
    if (( pending )); then
      snapshot
    fi
  else
    echo "inotifywait exited; restarting" >&2
    exit 1
  fi
done
