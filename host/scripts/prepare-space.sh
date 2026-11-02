#!/bin/bash
# One-time setup of a SilverBullet space that Hermes Agent will write into.
#
# Usage: sudo ./prepare-space.sh /srv/silverbullet/space 1000
set -euo pipefail

SPACE="${1:?space directory}"
OWNER="${2:-1000}"

mkdir -p "$SPACE"
# Everything that writes here -- SilverBullet, the agent, the snapshot
# watcher -- must run as this uid. A file owned by anyone else is one
# SilverBullet cannot save.
chown -R "$OWNER:$OWNER" "$SPACE"

# SilverBullet has no page history. Its indexer skips hidden directories, so a
# .git here is invisible to it.
if [ ! -d "$SPACE/.git" ]; then
  sudo -u "#$OWNER" git -C "$SPACE" init -q
fi

# Only if missing, so a re-run never clobbers entries you have added.
if [ ! -e "$SPACE/.gitignore" ]; then
  cat > "$SPACE/.gitignore" <<'EOF'
# SilverBullet's JWT signing secret -- never commit it.
.silverbullet.auth.json
# Downloaded plug code; reinstalls itself.
_plug/
EOF
  chown "$OWNER:$OWNER" "$SPACE/.gitignore"
fi

echo "Prepared $SPACE"
