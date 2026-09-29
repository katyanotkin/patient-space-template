---
description: Periodic tidy so the files don't bloat or go stale (monthly)
---
Propose changes, show the diff, apply only what the patient approves.

1. `TODO.md`: move completed items to Done; archive Done older than 30 days to
   `records/todo-archive-<YYYY-MM>.md`; flag "waiting on" items past follow-up.
2. `APPOINTMENTS.md`: move past visits to Past with their outcome link; flag
   past appointments with no outcome file.
3. `HEALTH.md`: resolve or strike threads that are done; check facts that
   contradict `TIMELINE.md`; verify the meds table against the latest visit
   outcomes.
4. `TIMELINE.md`: archive prior years to `records/timeline-<year>.md`.
5. `CARE-TEAM.md`: update "last seen" and "doesn't have".
6. Check no file contains a remote URL or credential; confirm the folder still
   has no git remote.
7. Append durable, patient-specific lessons to the relevant role's `Learnings`.
