# patient-space

A local-first workspace for organizing your own health affairs with an AI
assistant (built for Claude Code). It keeps your records in plain Markdown on
your own machine and gives the assistant a fixed structure and set of
routines, so it can help you with things like:

- **What is coming up, and what should I do about it?** (schedule guidance)
- **What do I say at my next appointment?** (visit prep: agenda, questions, what to bring)
- **What happened at the last one?** (visit debrief into durable records)
- **Are my meds/records consistent?** (reconciliation, follow-up tracking)

It is decision support for talking to real clinicians. **Not medical advice.**
It is not a diagnosis, a prescription, or a substitute for care. In an
emergency, call your local emergency number. Released under the MIT license
(see `LICENSE`), provided as is, without warranty.

## Privacy model (read first)

- **This repo is templates only. Your data must never be pushed.**
  Clone it locally and run `./init.sh`. That copies `templates/*.md` to
  working files in the root. Those files, `records/*` and `visits/*` are
  ignored: `.gitignore` is an allowlist, and commit/push hooks reject any
  path that is not on `.githooks/allowed-paths.sh`.
- The templates in `templates/` are read-only. Edit the root copies, not
  the templates.
- Never add a remote that points anywhere but this template's origin, and
  never `git add -f` your working files. The hooks are a safety net against
  accidents, not a guarantee.
- No telemetry from this template. What the assistant reads is sent to
  Anthropic to answer. For what that means, and for cloud-synced folders,
  shared or lost computers, and assistant mistakes, see the privacy section of
  `PATIENT-GUIDE.md`.

## Layout

```
PATIENT-GUIDE.md   Plain-language guide for patients (start here if non-technical).
SETUP.md           Setup steps for you or a helper.
CLAUDE.md          Assistant operating rules: boundaries, interaction style, routing
HEALTH.md          (created by init.sh from templates/) CURRENT STATE snapshot: profile, conditions, meds, allergies,
                   family history, screenings. Edited in place; history struck through.
TIMELINE.md        Append-only dated log of events, findings, changes.
CARE-TEAM.md       Clinicians, contacts, portals, and what each one owns.
APPOINTMENTS.md    Upcoming + past appointments, one row each, linked to visit folders.
TODO.md            Actions only (calls, forms, questions to send). No health facts.
visits/            One folder per appointment: prep.md before, outcome.md after.
records/           Labs, imaging, letters, forms, call scripts.
templates/         Read-only blanks: HEALTH, TIMELINE, CARE-TEAM, APPOINTMENTS, TODO,
                   plus prep / outcome / symptom-log / call-script files.
init.sh            Creates the root working files from templates (never overwrites).
.claude/agents/    writer: plain-language writer for guides and onboarding text.
.claude/roles/     pc (director) + skeptic always; optional specialist seats.
.claude/commands/  Routines: /start /checkin /prep /debrief /schedule /medrec /log /housekeeping
tools/reminders/   Optional: local reminder scheduling (not included yet).
```

## Design decisions

1. **Four kinds of information, four homes.** Facts (`HEALTH.md`), events
   (`TIMELINE.md`), actions (`TODO.md`), documents (`visits/`, `records/`).
   Mixing them was the main source of duplication and drift in the setup this
   is derived from.
2. **`HEALTH.md` is a snapshot, not a diary.** Chronology lives in
   `TIMELINE.md`. The assistant reads the snapshot cheaply every session.
3. **Routines are commands, not prose.** Each recurring activity is a command
   file with fixed inputs, steps, and outputs, so behavior is repeatable.
4. **Roles are optional lenses.** Only `pc` and `skeptic` are mandatory.
   Specialist seats are chosen per patient at `/start`; none are hardcoded.
5. **The assistant asks before it interprets.** History-taking style, never
   narrating a motive onto a fact you shared.
6. **Hard limits are in the always-loaded file**, not in a role: no diagnosis
   as fact, no dose/prescription changes, red flags stop everything, crisis
   resources come first.
7. **Housekeeping is a routine.** Recency sections rotate, done items move,
   stale follow-ups get surfaced. Otherwise the files bloat.

## Quickstart

0. Non-technical? Start with `PATIENT-GUIDE.md`.
1. Clone this repo locally.
2. Follow `SETUP.md`.
3. Open Claude Code in the folder and run `/start`.
