---
description: Quick symptom log entry (30 seconds); keeps a running log for visit prep
argument-hint: <symptom>
---
Add one entry to a symptom log. Keep it fast, and let the patient skip any field.

1. Red-flag screen first (`pc.md`). If anything applies, stop and follow it.
2. Find `records/*symptom-log-<symptom>.md`. If none, create it from
   `templates/symptom-log.md` as `records/YYYY-MM-DD-symptom-log-<symptom>.md`
   and add a one-line open thread in `HEALTH.md` linking to it.
3. Ask only for what is missing, in one short line: what happened, how bad
   (0-10), how long, what they were doing, anything that helped or made it
   worse. Date and time default to now. Skip anything they don't know.
4. Append one row. Record their words, no interpretation and no guessed causes.
5. Update the "Summary for a clinician" (how often, pattern, trend, what was
   tried) only from what is logged. Say when there is too little to see a
   pattern.
6. Mention `/prep` uses this log. Do not push the patient to log more often.
   If they say "don't ask again", record it under Assistant preferences in
   `HEALTH.md`.
