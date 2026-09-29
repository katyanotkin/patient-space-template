# Setup

1. **Clone** this repo to a local folder.
2. **Run `./init.sh`.** It copies `templates/HEALTH.md`, `TIMELINE.md`,
   `CARE-TEAM.md`, `APPOINTMENTS.md` and `TODO.md` into the root as your
   working files. It never overwrites existing files. The templates are
   read-only; edit only the root copies. It also enables `.githooks/`, whose
   hooks reject commits (and pushes) containing private data or modifying `templates/`
   (override: `ALLOW_TEMPLATE_EDIT=1`). It also disables pushing
   (`origin` push URL set to `DISABLED`), so your clone is read-only.
   Template maintainer: `KEEP_PUSH=1 ./init.sh`.
3. **Check git ignores them:** `.gitignore` is an allowlist (`*`, then only
   published template files re-included), so any new file is ignored by
   default. `git status` should show nothing new after you add data. The
   hooks in `.githooks/` reject commits and pushes with any path not on
   `.githooks/allowed-paths.sh`, even with `git add -f` or `--no-verify`
   on commit. Do not add remotes to your working clone.
4. **Rename** nothing. Paths are referenced by the commands.
5. **Open Claude Code** in the folder and run `/start`. It interviews you
   like a clinician taking a history and fills `HEALTH.md`, `CARE-TEAM.md`,
   `APPOINTMENTS.md`. Skip anything you don't want recorded.
6. **Choose seats** for the panel at the end of `/start` (see
   `.claude/roles/panel.md`). Add specialists by copying
   `.claude/roles/_TEMPLATE.md`.
7. Use `/checkin` at the start of later sessions, `/prep` before a visit,
   `/debrief` after.
