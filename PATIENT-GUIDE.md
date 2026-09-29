# patient-space: a guide for patients

## What is this?

A folder on your own computer where your health information lives in plain files.
An AI assistant (Claude) reads those files and helps you keep them organized. It introduces itself as your health navigator: it helps you organize, understand, and prepare for your care, and it is not a clinician.

Think of it as a well-run health binder that can also talk back.

## What does it help with?

- **Keeping track.** Your medicines, allergies, conditions, and clinicians in one place.
- **Getting ready for a visit.** What to say, what to ask, what to bring.
- **Remembering what happened.** After a visit, it helps you write down what the clinician said and what you need to do next.
- **Knowing what is coming up.** Appointments, follow-ups, and things you have not booked yet.
- **Understanding.** Plain-language explanations of medical words, tests, and results. These are general, not about your own case; your clinician can say what they mean for you.
- **Spotting mix-ups.** For example, the medicine list at home not matching what your doctor has.

## What does it not do?

- It does not diagnose you.
- It does not tell you to start, stop, or change a medicine. For that, ask your prescriber (the person who wrote the prescription).
- It does not replace your doctor, nurse, or pharmacist.
- It can make mistakes. Confirm anything important with a clinician.
- It is not for emergencies. If you think you are in danger, call your local emergency number.
- If you ever think about hurting yourself, contact a crisis line right away (988 in the US, or your local crisis line). The assistant will point you there first.

## Is my information private?

Partly, and you should know exactly which part.

- **Your files stay on your computer.** This tool does not upload them or sync them anywhere.
- **What you type, and the contents of the files the assistant reads, are sent to Anthropic** so it can answer. That includes things like `HEALTH.md` and your visit notes. Read their data terms if that matters to you.
- **It is set up to block accidental uploads to GitHub.** That is a safety net, not a guarantee. Do not add other remotes or force-add files.
- **Cloud-synced folders.** Do not put this folder in iCloud, Dropbox, OneDrive or Google Drive unless you are comfortable with your records being copied there.
- **Shared or lost computer.** Turn on disk encryption and a screen lock, so others cannot read your files.
- Share only what you are comfortable sharing. You can skip any question.

## What do I need?

- A computer (Mac, Linux, or Windows; see "Using Windows" below).
- Claude Code, the program that runs the assistant. It needs an Anthropic account and a plan that includes Claude Code.
- git, a free tool that copies the project to your computer. Mac and Linux often have it already; type `git --version` to check. Windows users install it below.
- A helper for the first setup, if you do not use a terminal (the text window where you type commands). It takes about 10 minutes. After that, you talk to the assistant in plain sentences.

## Using Windows

The setup steps below use a terminal that understands Linux-style commands. On Windows, pick one:

- **Git Bash (simplest).** Install Git for Windows from git-scm.com. Then open "Git Bash" from the Start menu and use it everywhere this guide says "terminal".
- **WSL.** Windows Subsystem for Linux gives you a Linux terminal inside Windows. Open PowerShell and type `wsl --install`, restart, then use the Ubuntu app as your terminal.

We have not tested these steps on Windows. If something does not work, ask a helper who knows the terminal.

## How do I set it up? (one time)

Ask your helper to do these with you.

1. Copy the project to your computer: `git clone <the link you were given>`
   The link looks like `https://github.com/some-name/patient-space-template.git`.
2. Open the new folder in the terminal.
3. Type `./init.sh` and press Enter.
   This creates your personal files, blank and ready. It also sets up protection against accidental uploads.
4. Type `claude` and press Enter to start the assistant.
5. Type `/start`.

`/start` is an interview. You only need to run it once. The assistant asks about your health history the way a clinician would, one question at a time. Skip anything you do not want to record.

## How do I use it day to day?

Type these commands in the assistant. Each does one job.

| Type this | When | What happens |
|---|---|---|
| `/checkin` | Start of each session | It asks how open follow-ups are going |
| `/schedule` | Any time | Tells you what is due and what is not booked |
| `/prep` | Before a visit | Helps you plan what to say and ask |
| `/debrief` | After a visit | Captures what happened and what to do next |
| `/log` | When a symptom happens | Adds a quick entry to a symptom log for your next visit |
| `/medrec` | Any time | Checks your medicine list for mismatches to show your prescriber |
| `/housekeeping` | About monthly | Tidies old items away |

You can also just talk to it: "My knee has hurt for two weeks. What should I tell my doctor?" It will ask you questions first, then help you prepare.

Any question the assistant asks can be skipped. Say "skip" to move on, "never mind" to drop the topic, or "don't ask again" and it will remember.

## Where does my information go?

**Saved:** only in your folder, in files you can open with any text editor. Nothing is stored anywhere else by this tool.

**Sent for answers:** each time the assistant looks something up to answer you, it reads the relevant files and sends that text, plus what you typed, to Anthropic's AI. That is a trip out and back for that answer. The AI's reply comes back and the assistant writes any updates to your local files.

Your files:

- `HEALTH.md`: your current health facts
- `TIMELINE.md`: a dated log of what happened
- `CARE-TEAM.md`: your clinicians and how to reach them
- `APPOINTMENTS.md`: dates
- `TODO.md`: things to do
- `visits/` and `records/`: visit notes, lab results, letters

It labels what a clinician confirmed and what you told it, and it does not save guesses as facts. Medicine changes are recorded only when your prescriber made them.

## If something goes wrong

- **`./init.sh` says permission denied.** Type `chmod +x init.sh`, then try again.
- **A command like `/start` is not found.** Make sure you started `claude` from inside the project folder.
- **You entered something wrong.** Tell the assistant. Old values are crossed out, not erased, so nothing is lost.

## A last note

This tool helps you keep your health information organized and understandable, so you can take a full part in your care. The decisions stay between you and your clinicians.
