---
description: After a visit, capture what happened and route it to the right files
argument-hint: <clinician or date>
---
1. Open the matching `visits/.../` folder (create from `templates/visit-outcome.md`).
2. Ask: what did they say or find; any diagnosis; any medication change
   (before/after, quantity dispensed); orders or referrals; follow-up dates;
   what you're to do; what they're to do; what you forgot to ask.
3. Record the clinician's words, not interpretation. Where the patient's
   understanding differs from what was said, note it and suggest a clarifying
   portal message.
4. Route: facts → `HEALTH.md` (strike superseded values); event →
   `TIMELINE.md`; next visit → `APPOINTMENTS.md`; actions → `TODO.md`; new
   records → `records/`; "didn't have" updates → `CARE-TEAM.md`.
5. Check that the visit's prep questions were answered; carry the rest forward.
6. Run `/medrec` if any medication changed.
