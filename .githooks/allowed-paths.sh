# ALLOWLIST: the only paths that may ever be committed or pushed.
# Everything else (patient data, notes, scans, new files) is rejected.
# To publish a new template file, add its pattern here AND to .gitignore.
# `*` in a case pattern also matches "/", so keep patterns specific.
is_allowed() {
  case "$1" in
    .claude/roles/registry.md) return 1 ;;   # auto-generated, never published
    .gitignore|README.md|SETUP.md|CLAUDE.md|PATIENT-GUIDE.md|LICENSE|init.sh) return 0 ;;
    .githooks/pre-commit|.githooks/pre-push|.githooks/allowed-paths.sh) return 0 ;;
    templates/*.md) [[ "$1" != templates/*/* ]] && return 0 ;;
    .claude/agents/*.md) [[ "$1" != .claude/agents/*/* ]] && return 0 ;;
    .claude/commands/*.md) [[ "$1" != .claude/commands/*/* ]] && return 0 ;;
    .claude/roles/library/*.md) [[ "$1" != .claude/roles/library/*/* ]] && return 0 ;;
    .claude/roles/*.md) [[ "$1" != .claude/roles/*/* ]] && return 0 ;;
    tests/README.md|tests/run-tests.sh) return 0 ;;
    records/README.md|visits/README.md|tools/reminders/README.md) return 0 ;;
  esac
  return 1
}
# filter_disallowed: read paths on stdin, print those NOT on the allowlist.
filter_disallowed() { while IFS= read -r p; do is_allowed "$p" || printf '%s\n' "$p"; done; }
