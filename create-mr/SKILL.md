---
name: create-mr
description: "Turn a committed branch into a merge request in GitLab through the glab CLI: push it, title it after the task and link the task in the description, and give back the link. Trigger on «создай MR», «оформи мерж реквест», «запушь и создай MR», «на ревью», create MR, merge request, open a PR. Expects the work to be committed already — committing is the commit skill, and reviewing somebody else's MR is review-mr."
compatibility: "Needs git and `glab` authenticated against your GitLab instance."
metadata:
  source: "https://github.com/TechTechWizard/dev-skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Grep Glob Bash
---

# Create a merge request

Everything said to the developer is in the language they are speaking, from the first
line to the last: a stop on an uncommitted file, a question about the task or the blocker,
a refusal, a failed push and the final link all follow the same rule. The stops matter
most here, because that is when the developer has to decide what goes into a client's
repository, and a question they have to translate first is the one most easily misread.
The title and the description of the merge request stay in English, because the
reviewer may not share that language.

## Before anything

```sh
git remote -v
git branch --show-current
git status
git log <target>...HEAD --oneline
git diff <target>...HEAD --stat
```

These are local and answer at once, so they come before any `glab` call: `glab` talks
to the network and needs a remote to talk to, and on a clone with none it only returns
an error that `git remote -v` had already given for free. Nothing in this skill calls
`glab` until the remote is known to exist.

`<target>` is the project's integration branch — `development` on most, but read the
project's own `CLAUDE.md` or its recent merge requests (`glab mr list`, after the remote
is confirmed) before assuming.

**Uncommitted changes stop this.** List them and ask: commit them first with the
`commit` skill, or proceed and leave them behind. Never decide that for the developer;
a file they were mid-way through is not something to sweep into a merge request, and a
merge request without it is not what they meant to send either. Untracked files are
part of this, not an exception: a file the developer wrote and forgot to add is
untracked, and "it cannot reach the branch" is precisely the problem. When nobody can
answer — an unattended run, a prompt with no one behind it — stopping means ending
with the list and no push, because the rule protects the file the developer is in the
middle of, and a run that cannot ask cannot know which file that is.

## The task reference

The id opens the branch name, `{TASK_ID}-{description}`, and it counts only when it
looks like one. A custom id such as `ABC-123` carries a hyphen of its own, so it is taken
whole: capital letters, a hyphen, digits. Otherwise the id is the first segment when that
segment is a ClickUp id — at least seven lowercase letters and digits, starting with a
digit and with letters among them, so a date or a version number is not one. A branch
like `cleanup-logging`, `oauth2-login` or `<nickname>/cleanup-logging` carries none —
the team's convention names a branch without a task after its author — and that is an
answer, not a gap: nothing is asked, and the merge request goes out without a task
reference, as the title section below describes.

With an id, read the task's name and its link: through the `clickup` skill when it is
installed, or `clickup task <TASK_ID>`, whose output carries both. The link is the one
ClickUp gives for the task. When ClickUp cannot be reached — no CLI, no token — the link
is built from the id: `https://app.clickup.com/t/{TASK_ID}` for a ClickUp id, and for a
custom id `https://app.clickup.com/t/<workspace_id>/{TASK_ID}`, with the workspace number
taken from the project's `CLAUDE.md`. Two cases stop the run with a question instead,
because the link they would produce opens nothing: ClickUp answers that it does not know
the id, which is usually a typo in the branch name, and a custom id with no workspace
number anywhere. A run with nobody to answer ends there, with the reason and no merge
request: a guessed link would reach the customer, and a dropped one would hide the task.

## Branched from another unmerged branch

The team's convention for decomposed work is a branch cut from another branch that is
done but not yet merged, so that review does not block the next step. Its merge request
still targets `<target>`, and the description names the merge request to review first.
Find it among the open merge requests into `<target>`, skipping the one from the current
branch itself:

```sh
glab mr list --target-branch "<target>" --per-page 100 --output json  # open ones
git fetch origin
fork=$(git merge-base HEAD "origin/<source_branch>")
git merge-base --is-ancestor "$fork" "origin/<target>"     # 1: shared unmerged commits
git merge-base --is-ancestor HEAD "origin/<source_branch>"  # 1: not cut from ours
```

A merge request is a blocker when both checks answer `1`: our branch carries its
commits that `<target>` does not have yet, and it is not a branch cut from ours. The
fork point is compared rather than the branch tip, because the blocker's branch usually
moves on after ours was cut — review fixes land there — and its new tip is no longer in
our history. When several merge requests qualify, the blocker is the nearest one, the
one whose fork point contains the others' — that is the merge request this one waits on
directly. When they cannot be ordered that way, name them and ask rather than pick.

Once both branches have moved on, git alone cannot tell which was cut from which, so
these checks rest on the order decomposition follows: the earlier part has its merge
request open before the later part asks for one. A merge request from a branch cut from
ours is not expected to exist yet; the final message names the blocker it found, so a
wrong one is seen at once.

## Title and description

The format is the company's, and it is the same whichever tool opens the merge request.

Title: `{TASK_ID}: {Task name}`, where the task name is the task's own name translated
into English — not a summary of the commits, and not shortened to fit a length. When
the task has an id but its name could not be read, the part after the colon states what
the change does, worded from the diff, in English. Without an id the title is the
subject of the last commit that is not a merge, exactly as written
(`git log -1 --no-merges --format=%s <target>..HEAD`), so a commit that came in
with a merge of `<target>` never names this branch.

A draft is asked for with `--draft` on `glab mr create`, and the title stays exactly as
above. `glab` puts `Draft:` in front of the title itself when the flag is passed, so a
title that already carries the prefix arrives as `Draft: Draft: …`, and the notification
about it has gone to the project's members before anyone can fix the title.

Description: one line with the task link, a second line when the branch has a blocker,
and empty when there is neither a task id nor a blocker — however many commits and files
the branch has.

```
Task: <task link>
Blocker: !<iid>
```

`<task link>` is the link the task reference section produced. Without a task id there
is no `Task:` line, and the description is the `Blocker:` line alone or empty. No
summary, no test plan, no checklist, no list of files. The reviewer reads the diff and
the task; the description points at them.

Nothing else is appended — no "Generated with" line, no co-author trailer, no emoji.
Some hosts tell the session by default to end every pull request description with such
a line; that default is written for the host's own pull requests, and it does not reach
a description whose shape this skill fixes. A merge request on a client project is read
by the customer, and whether the customer is told which tools wrote the code is the
company's decision, not a line a host adds by habit.

## Create it

```sh
git push -u origin "<branch>"
glab mr create \
  --source-branch "<branch>" \
  --target-branch "<target>" \
  --title "<title>" \
  --yes \
  --description "$(cat <<'BODY'
...
BODY
)"
```

Use a HEREDOC for the body, or the formatting arrives mangled. An empty description is
still passed, as `--description ""`: `glab` checks whether the flag was given, not what
it holds, and without the flag it opens its description editor in a terminal even with
`--yes`. `--yes` is there because
`glab mr create` asks "What's next?" after the title and description are set, even
when both were passed on the command line; in a terminal that is one keypress, in a
session with nobody at the keyboard it hangs the run. With the title and the
description given, that confirmation is the only prompt left, so the flag skips
nothing the skill wanted asked. For a draft, `--draft` joins this same command, with the
title unchanged. A branch with a blocker still targets `<target>`, never the blocker's
branch: the `Blocker:` line is what orders the review, and a merge request into the
blocker's branch would be merged into it rather than into `<target>`.

Then print the link, the title, the target branch and the blocker when there is one, in
the developer's language like everything else this skill says to them.

## Never

- Never force-push. If the branch has diverged, say so and let the developer decide.
- Never a merge request from an unpushed branch — push first, and if the push fails,
  stop and report the failure rather than creating something that points at nothing.
- Never merge it yourself.
