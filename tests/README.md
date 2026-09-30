# Tests: what they are and why

These are automatic checks. They answer one question: **is this tool still
safe and working the way it says it is?**

You do not need to run them to use patient-space. They are here so that
whoever changes the template (a helper, a developer, or you) can tell quickly
whether a change broke something.

## What they check, in plain words

- **Your data stays private.** Your personal files (`HEALTH.md`, `records/`,
  `visits/` and so on) cannot be saved into git or pushed anywhere by
  accident. The checks try to do exactly that and confirm it gets blocked.
- **Setup works.** `./init.sh` creates your blank files, never overwrites
  what you already wrote, and turns off pushing.
- **The blank forms are complete.** The templates have the sections the
  assistant expects.
- **The assistant's instructions hang together.** Every command file points to
  files and steps that exist, and the steps are numbered in order.

## What they do not check

They do not check what the assistant says to you. That depends on the AI and
can vary from one answer to the next, so it can't be tested this way.

## How to run them

In the terminal, from the project folder:

    bash tests/run-tests.sh

Works on a temporary copy, so your real files are not changed or sent
anywhere. It takes about a minute. At the end it prints `TOTAL pass=N fail=0`.
If a line starts with `FAIL`, something is wrong. Ask your helper, or tell the
assistant what you changed.

Note: the "no patient file shows up as untracked" check may flag a brand-new
file you just added and have not committed yet. That is not a problem with
your data.

## Adding a new template file?

Add it in two places so the safety checks still agree: `.gitignore` and
`.githooks/allowed-paths.sh`. The tests will tell you if the two lists
disagree.
