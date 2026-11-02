#!/bin/bash
# One-time setup of a SilverBullet space that Hermes Agent will write into.
#
# Usage: sudo ./prepare-space.sh /srv/silverbullet/space 1000
set -euo pipefail

SPACE="${1:?space directory}"
OWNER="${2:-1000}"

mkdir -p "$SPACE"
chown -R "$OWNER:$OWNER" "$SPACE"

# Hermes' file tools write as root even with PUID set, and a root-created
# note is read-only to SilverBullet. A DEFAULT ACL is inherited by files
# created later, whoever creates them; a chown only fixes what exists now.
# The mask entry is needed too, or the group entry is clamped and the write
# is still denied.
setfacl -d -m "g:$OWNER:rwx" -m "m::rwx" "$SPACE"

# SilverBullet has no page history. Its indexer skips hidden directories, so a
# .git here is invisible to it.
if [ ! -d "$SPACE/.git" ]; then
  sudo -u "#$OWNER" git -C "$SPACE" init -q
fi

cat > "$SPACE/.gitignore" <<'EOF'
# SilverBullet's JWT signing secret -- never commit it.
.silverbullet.auth.json
# Downloaded plug code; reinstalls itself.
_plug/
EOF
chown "$OWNER:$OWNER" "$SPACE/.gitignore"

echo "Prepared $SPACE"
