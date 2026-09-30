#!/usr/bin/env bash
# Safety and consistency checks for the template. See tests/README.md.
# Run from anywhere:  bash tests/run-tests.sh
# Works on a temporary copy of this folder; your real files are never touched.
REPO=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
PRISTINE=$WORK/pristine; cp -r "$REPO" "$PRISTINE"
W=$WORK/w; mkdir -p "$W"
export GIT_SSH_COMMAND=false   # no test can ever reach a real remote
pass=0; fail=0
ok(){ pass=$((pass+1)); echo "PASS  $1"; }
no(){ fail=$((fail+1)); echo "FAIL  $1  :: ${2:-}"; }
t(){ # t "name" cmd...
  local n=$1; shift; if "$@" >/dev/null 2>&1; then ok "$n"; else no "$n"; fi; }
fresh(){ local d=$W/$1; rm -rf $d; cp -r $PRISTINE $d; echo $d; }
git_q(){ git -c user.name=qa -c user.email=qa@example.invalid "$@"; }

echo "## init.sh"
D=$(fresh init1); cd $D
out=$(./init.sh 2>&1)
for f in HEALTH TIMELINE CARE-TEAM APPOINTMENTS TODO; do t "init creates $f.md" test -f $f.md; t "$f.md identical to template" cmp $f.md templates/$f.md; done
t "init creates records/ and visits/" test -d records -a -d visits
t "hooksPath=.githooks" test "$(git config core.hooksPath)" = .githooks
[ "$(git remote get-url --push origin)" = DISABLED ] && ok "push URL disabled by default" || no "push URL disabled" "$(git remote get-url --push origin)"
t "fetch URL untouched" test "$(git remote get-url origin)" = git@github.com:katyanotkin/patient-space-template.git
# idempotent / never overwrite
echo "MY DATA" >> HEALTH.md; sum1=$(md5sum HEALTH.md)
out2=$(./init.sh 2>&1); sum2=$(md5sum HEALTH.md)
[ "$sum1" = "$sum2" ] && ok "re-run never overwrites HEALTH.md" || no "overwrite"
echo "$out2" | grep -q "keep   HEALTH.md" && ok "re-run reports keep" || no "keep msg"
echo "$out2" | grep -q "^create" && no "re-run created something" "$out2" || ok "re-run creates nothing"
[ "$(git remote get-url --push origin)" = DISABLED ] && ok "still DISABLED after rerun" || no "rerun push"
# delete one file -> only that recreated
rm TODO.md; ./init.sh >/dev/null 2>&1; t "deleted TODO.md recreated" test -f TODO.md; grep -q "MY DATA" HEALTH.md && ok "other files untouched on partial recreate" || no "partial"
# read-only template copy is writable
D=$(fresh init2); cd $D; chmod a-w templates/HEALTH.md; ./init.sh >/dev/null 2>&1; test -w HEALTH.md && ok "root copy writable even if template read-only" || no "chmod u+w"
# KEEP_PUSH
D=$(fresh init3); cd $D; KEEP_PUSH=1 ./init.sh >/dev/null 2>&1
[ "$(git remote get-url --push origin)" != DISABLED ] && ok "KEEP_PUSH=1 keeps push" || no "KEEP_PUSH"
# no remote
D=$(fresh init4); cd $D; git remote remove origin; t "init works with no remote" ./init.sh
# run from another cwd
D=$(fresh init5); cd /; t "init.sh runnable from another cwd" bash $D/init.sh; test -f $D/HEALTH.md && ok "  ...files created next to script" || no "cwd"
# not a git repo
D=$(fresh init6); cd $D; rm -rf .git; t "init works outside git (no hooks)" ./init.sh

echo "## .gitignore + hooks"
D=$(fresh git1); cd $D; ./init.sh >/dev/null 2>&1
mkdir -p records visits/2026-10-05-cardiology
echo x > records/x; echo y > visits/2026-10-05-cardiology/prep.md; echo z > .claude/roles/registry.md; echo n > notes.txt; echo p > scan.pdf
echo "" > /dev/null
for f in HEALTH.md TIMELINE.md CARE-TEAM.md APPOINTMENTS.md TODO.md records/x visits/2026-10-05-cardiology/prep.md .claude/roles/registry.md notes.txt scan.pdf records/2026-01-01-lab.md; do
  mkdir -p $(dirname $f); [ -e $f ] || echo t > $f
  git check-ignore -q $f && ok "gitignored: $f" || no "gitignored: $f"
done
t "no patient file shows up as untracked" test -z "$(git status --porcelain --untracked-files=all | grep "^??")"
for f in records/README.md visits/README.md templates/HEALTH.md CLAUDE.md .claude/commands/start.md .claude/roles/navigator.md .claude/roles/library/pharmacist.md; do
  git check-ignore -q $f && no "should NOT be ignored: $f" || ok "not ignored: $f"; done
# new-command file added in allowlisted dir is trackable
echo "---" > .claude/commands/new.md; git check-ignore -q .claude/commands/new.md && no "new command ignored" || ok "new .claude/commands/*.md not ignored"
# nested is ignored
mkdir -p .claude/commands/sub; echo a > .claude/commands/sub/a.md; git check-ignore -q .claude/commands/sub/a.md && ok "nested commands/sub ignored" || no "nested not ignored"

# pre-commit via force add
try_commit(){ git_q commit -q -m t "$@" 2>&1; }
for f in HEALTH.md records/x visits/2026-10-05-cardiology/prep.md .claude/roles/registry.md notes.txt scan.pdf; do
  git reset -q; git add -f $f; out=$(try_commit); rc=$?
  [ $rc -ne 0 ] && echo "$out" | grep -q "allowlist" && ok "pre-commit rejects $f" || no "pre-commit rejects $f" "rc=$rc $out"
  git reset -q; done
# multi: allowed + disallowed
git reset -q; git add -f .claude/commands/new.md HEALTH.md; out=$(try_commit); rc=$?; [ $rc -ne 0 ] && ok "mixed staged set rejected" || no "mixed"; git reset -q
# lookalike paths
for f in HEALTH.md.bak README.md.bak templates/HEALTH.txt templates/sub/x.md .claude/roles/library/sub/x.md .claude/roles/sub/x.md records/README.md.bak visits/sub/README.md; do
  mkdir -p $(dirname $f); echo t > $f; git reset -q; git add -f $f; out=$(try_commit); rc=$?
  [ $rc -ne 0 ] && ok "pre-commit rejects lookalike $f" || no "pre-commit accepts lookalike $f"; git reset -q; git rm -q --cached -f $f 2>/dev/null; done
# filename with spaces/newline-ish/unicode
f="records/my lab é.md"; echo t > "$f"; git add -f "$f"; out=$(try_commit); [ $? -ne 0 ] && ok "pre-commit rejects unicode/space record path" || no "unicode path accepted"; git reset -q
# allowed commit passes (non-template)
echo "# tweak" >> README.md; git add README.md; out=$(try_commit); [ $? -eq 0 ] && ok "allowlisted README.md commit passes" || no "README commit" "$out"
# templates read-only
chmod u+w templates/HEALTH.md; echo "# edit" >> templates/HEALTH.md; git add templates/HEALTH.md; out=$(try_commit); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q "read-only" && ok "template edit blocked" || no "template edit blocked" "$out"
ALLOW_TEMPLATE_EDIT=1 git_q commit -q -m t >/dev/null 2>&1 && ok "ALLOW_TEMPLATE_EDIT=1 permits template edit" || no "override"
# template deletion
git rm -q templates/TODO.md; out=$(try_commit); [ $? -ne 0 ] && ok "template deletion blocked" || no "template deletion allowed"; git reset -q --hard
# template rename out (rename to bad path): -> ACMR includes R
git mv templates/TODO.md records/TODO-copy.md 2>/dev/null; out=$(try_commit); [ $? -ne 0 ] && ok "rename template->records blocked" || no "rename slipped"; git reset -q --hard
# --no-verify then pre-push
D=$(fresh push1); cd $D; ./init.sh >/dev/null 2>&1
git remote set-url --push origin "$W/bare.git"; rm -rf $W/bare.git; git init -q --bare $W/bare.git
git remote set-url origin "$W/bare.git"
echo secret > HEALTH.md; git add -f HEALTH.md; git_q commit -q --no-verify -m leak
out=$(git push origin main 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q "pre-push: refusing" && ok "pre-push blocks --no-verify'd HEALTH.md" || no "pre-push blocks" "rc=$rc $out"
[ -z "$(git -C $W/bare.git branch)" ] && ok "bare remote received nothing" || no "bare got data"
# push with patient file in an OLDER commit and a clean newer commit
git rm -q --cached HEALTH.md; git_q commit -q -m rm; out=$(git push origin main 2>&1); [ $? -ne 0 ] && ok "pre-push catches leaked file in earlier unpushed commit" || no "history leak passes push"
# clean history pushes: fresh
D=$(fresh push2); cd $D; ./init.sh >/dev/null 2>&1; git remote set-url --push origin "$W/bare2.git"; rm -rf $W/bare2.git; git init -q --bare $W/bare2.git
echo "# x" >> README.md; git add README.md; git_q commit -q -m ok; out=$(git push origin main 2>&1); [ $? -eq 0 ] && ok "clean allowlisted push works" || no "clean push" "$out"
# --root new branch push with leak
git checkout -q -b leak; echo s > records/x; git add -f records/x; git_q commit -q --no-verify -m l; out=$(git push origin leak 2>&1); [ $? -ne 0 ] && ok "pre-push blocks new branch with leak" || no "new branch leak passes"
# delete branch push permitted
git push origin --delete leak >/dev/null 2>&1; 
# default push disabled
D=$(fresh push3); cd $D; ./init.sh >/dev/null 2>&1; out=$(git push origin main 2>&1); echo "$out" | grep -qi "DISABLED\|fatal\|does not appear" && ok "push to DISABLED fails" || no "push disabled" "$out"
# merge commit / tag containing leak? tag push
D=$(fresh push4); cd $D; ./init.sh >/dev/null 2>&1; git remote set-url --push origin "$W/bare4.git"; rm -rf $W/bare4.git; git init -q --bare $W/bare4.git
echo s > HEALTH.md; git add -f HEALTH.md; git_q commit -q --no-verify -m leak; git tag v1
out=$(git push origin v1 2>&1); [ $? -ne 0 ] && ok "pre-push blocks tag pointing to leak" || no "tag push leak passes"
# hook when hooksPath NOT set (fresh clone before init)
D=$(fresh nohook); cd $D; git config --unset core.hooksPath 2>/dev/null; echo s>HEALTH.md; git add -f HEALTH.md; git_q commit -q -m x >/dev/null 2>&1 && ok "INFO: without init.sh hooks are off (expected; commit allowed)" || ok "INFO hooks active even without init"

echo "## templates content"
cd $PRISTINE/templates
t "HEALTH has Assistant preferences" grep -q '^## Assistant preferences' HEALTH.md
t "HEALTH meds has Supply runs out col" grep -q 'Supply runs out' HEALTH.md
t "HEALTH meds has Refills left col" grep -q 'Refills left' HEALTH.md
t "HEALTH meds header column count = separator" bash -c '[ "$(grep -A1 "^| Name | Dose as" HEALTH.md | head -1 | tr -cd "|" | wc -c)" = "$(grep -A1 "^| Name | Dose as" HEALTH.md | tail -1 | tr -cd "|" | wc -c)" ]'
t "visit-prep has Before the day" grep -q '^## Before the day' visit-prep.md
t "visit-prep has Before you leave, ask" grep -q '^## Before you leave, ask' visit-prep.md
t "TODO has Results line" grep -q 'Results:' TODO.md
t "HEALTH has Foods and drinks section" grep -q '^## Foods and drinks' HEALTH.md
t "APPOINTMENTS has Needs booking" grep -q 'Needs booking' APPOINTMENTS.md
t "symptom-log has Summary for a clinician" grep -q 'Summary for a clinician' symptom-log.md
t "visit-outcome has Medication changes" grep -q 'Medication changes' visit-outcome.md
cd $PRISTINE
t "no em dashes in patient-facing docs (writer rule): README/SETUP/PATIENT-GUIDE" bash -c '! grep -l "—" README.md SETUP.md PATIENT-GUIDE.md'

echo "## commands: frontmatter, refs, steps"
cd $PRISTINE
for f in .claude/commands/*.md; do
  n=$(basename $f .md)
  [ "$(sed -n 1p $f)" = "---" ] && ok "$n: frontmatter opens" || no "$n frontmatter open"
  end=$(awk 'NR>1 && /^---$/{print NR; exit}' $f); [ -n "$end" ] && ok "$n: frontmatter closes" || no "$n frontmatter close"
  sed -n "2,$((end-1))p" $f | grep -q '^description: .\+' && ok "$n: description" || no "$n description"
  bad=$(sed -n "2,$((end-1))p" $f | grep -v -E '^(description|argument-hint|allowed-tools|model): ' | grep -v '^$'); [ -z "$bad" ] && ok "$n: only known keys" || no "$n unknown keys" "$bad"
  grep -q "\`/$n\`" CLAUDE.md && ok "$n: listed in CLAUDE.md routines" || no "$n missing from CLAUDE.md"
  grep -q "/$n" README.md && ok "$n: listed in README" || no "$n missing from README"
  # numbered steps sequential
  nums=$(sed -n "$((end+1)),\$p" $f | grep -oE '^[0-9]+\.' | tr -d . | tr '\n' ' ')
  exp=$(seq 1 $(echo $nums | wc -w) | tr '\n' ' ')
  [ "$nums" = "$exp" ] && ok "$n: steps sequential ($nums)" || no "$n steps" "got: $nums"
done
# refs to files
refs=$(grep -ohE '`[A-Za-z0-9_./<>*-]+\.(md|sh)`' .claude/commands/*.md $(ls .claude/roles/*.md | grep -v registry) .claude/roles/library/*.md CLAUDE.md | tr -d '`' | sort -u)
for r in $refs; do
  case "$r" in *'<'*|*'*'*) continue;; esac
  b=$(basename $r)
  if [ -e "$r" ] || [ -e ".claude/roles/$r" ] || [ -e "templates/$r" ] || [ -e ".claude/commands/$r" ] || [ -e ".claude/roles/library/$r" ] || [ -e "tools/reminders/$r" ]; then ok "ref exists: $r"
  else case "$r" in HEALTH.md|TIMELINE.md|CARE-TEAM.md|APPOINTMENTS.md|TODO.md|prep.md|outcome.md) ok "ref (runtime file): $r";; *) no "ref missing: $r";; esac; fi
done
# role refs in text (library/x.md) exist
for r in $(grep -ohE 'library/[a-z_-]+\.md' -r .claude CLAUDE.md | sort -u); do t "role ref $r" test -e .claude/roles/$r; done
# panel table roles exist in library
for r in $(sed -n '/Seat-on-trigger/,$p' .claude/roles/panel.md | grep -oE '^\| [a-z]+ \|' | tr -d '| ' | grep -v '^role$'); do t "panel role $r in library" test -e .claude/roles/library/$r.md; done
for f in .claude/roles/library/*.md; do r=$(basename $f .md); grep -qE "^\| $r \|" .claude/roles/panel.md && ok "library/$r listed in panel" || no "library/$r NOT in panel table"; done
for f in .claude/roles/*.md .claude/roles/library/*.md; do
  case $f in *_TEMPLATE*|*registry*|*panel*) continue;; esac
  grep -q '^## Charter' $f && grep -q '^## Body' $f && grep -q '^## Learnings' $f && ok "role structure: $(basename $f)" || no "role structure: $f"
done
# hard boundary line in every specialist
for f in .claude/roles/library/*.md; do grep -qiE 'boundary|never' $f && ok "boundary text: $(basename $f)" || no "no boundary line in $f"; done
# navigator step references
grep -q 'step 4 of `.claude/roles/navigator.md`' .claude/commands/schedule.md && grep -q '^4\. \*\*New appointment' .claude/roles/navigator.md && ok "schedule->navigator step 4 is new-appt" || no "schedule->navigator step ref"
grep -q 'Body step 3' .claude/roles/library/pharmacist.md && grep -q '^3\. \*\*Escalate' .claude/roles/library/pharmacist.md && ok "pharmacist 'Body step 3' = Escalate" || no "pharmacist step ref"
# navigator numbering
nums=$(awk '/^## Body/{f=1;next} /^## /{f=0} f' .claude/roles/navigator.md | grep -oE '^[0-9]+\.' | tr -d . | tr '\n' ' '); [ "$nums" = "1 2 3 4 5 6 7 8 9 " ] && ok "navigator steps sequential" || no "navigator steps" "$nums"
# allowlist sync: every git-tracked file is allowed by hook; .gitignore re-includes match
. .githooks/allowed-paths.sh
for f in $(git ls-files); do is_allowed "$f" && ok "tracked file allowed by hook: $f" || no "tracked file rejected by hook: $f"; done >/tmp/qa_sync.txt; grep -c FAIL /tmp/qa_sync.txt | sed 's/^/tracked-file-vs-hook FAIL count: /'; grep FAIL /tmp/qa_sync.txt; pass=$((pass+$(grep -c PASS /tmp/qa_sync.txt))); rm /tmp/qa_sync.txt
# files untracked-but-not-ignored in pristine copy
[ -z "$(git ls-files -o --exclude-standard)" ] && ok "no untracked-unignored files" || no "untracked unignored" "$(git ls-files -o --exclude-standard)"
# hooks executable
t "pre-commit executable" test -x .githooks/pre-commit; t "pre-push executable" test -x .githooks/pre-push; t "init.sh executable" test -x init.sh
t "bash -n init.sh" bash -n init.sh; t "bash -n hooks" bash -c 'bash -n .githooks/pre-commit && bash -n .githooks/pre-push && bash -n .githooks/allowed-paths.sh'
# CLAUDE.md content checks
grep -q 'Assistant preferences' CLAUDE.md && ok "CLAUDE.md defines Assistant preferences" || no "CLAUDE prefs"
grep -q '988' CLAUDE.md && ok "CLAUDE.md has 988" || no "988"
t "prep.md has story in brief step" grep -q 'story in brief' .claude/commands/prep.md
t "housekeeping never removes remote" grep -q 'Never propose removing a remote' .claude/commands/housekeeping.md
t "no bare library/ role path in commands" bash -c '! grep -nE "(^|[^/a-z])library/[a-z]+\.md" .claude/commands/*.md .claude/roles/navigator.md'
t "start.md privacy-setting question" grep -q 'privacy setting' .claude/commands/start.md
echo; echo "TOTAL pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
