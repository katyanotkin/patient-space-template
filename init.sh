#!/usr/bin/env bash
# Create your private working files from the read-only templates.
# Safe to re-run: never overwrites a file that already exists.
set -eu
cd "$(dirname "$0")"
for f in HEALTH TIMELINE CARE-TEAM APPOINTMENTS TODO; do
  if [ -e "$f.md" ]; then
    echo "keep   $f.md (already exists)"
  else
    cp "templates/$f.md" "$f.md"
    chmod u+w "$f.md"
    echo "create $f.md"
  fi
done
mkdir -p records visits

# Enable the tracked hooks (blocks commits that modify templates/)
git config core.hooksPath .githooks 2>/dev/null && echo "hooks  core.hooksPath=.githooks" || true

# Patients get a read-only clone: pushing is disabled. Maintainer of the
# template repo: run  KEEP_PUSH=1 ./init.sh  to keep push enabled.
if [ "${KEEP_PUSH:-}" != 1 ] && git remote get-url origin >/dev/null 2>&1; then
  git remote set-url --push origin DISABLED
  echo "push   disabled (read-only clone; KEEP_PUSH=1 to skip)"
fi
