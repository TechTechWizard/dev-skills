---
name: create-mr
description: "Turn a committed branch into a merge request in GitLab through the glab CLI: push it, title it after the task and link the task in the description, and give back the link. Trigger on «создай MR», «оформи мерж реквест», «запушь и создай MR», «на ревью», create MR, merge request, open a PR. Expects the work to be committed already — committing is the commit skill, and reviewing somebody else's MR is review-mr."
compatibility: "Needs git and `glab` authenticated against your GitLab instance. Reads a ClickUp task through the clickup CLI when the branch names one, and a GitLab issue through the same glab."
metadata:
  source: "https://github.com/TechTechWizard/dev-skills"
  update: "npx skills update -g"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Grep Glob Bash
---

# Create a merge request

Everything said to the developer is in the language they are speaking, from the first
line to the last: a stop on an uncommitted file, a question about the blocker,
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
looks like one. Three shapes do, tried in this order. A custom id such as `ABC-123`
carries a hyphen of its own, so it is taken whole: capital letters, a hyphen, digits.
Otherwise the id is the first segment when that segment is a ClickUp id — at least seven
lowercase letters and digits, starting with a digit and with letters among them, so a
date or a version number is not one. Otherwise the first segment is the number of a
GitLab issue when it is digits and nothing else and the segment after it is not digits
alone: `42-meter-readings` is issue 42, the iid GitLab shows in the issue's own address.
The second half of that condition is what keeps a date out, because `2026-10-16-cleanup`
opens with digits too and `2026` on its own would pass; its next segment, `10`, is
digits again, and a description never is. A version at the head of a branch,
`1.2.0-hotfix`, fails the first half, because the dots make it something other than
digits. The three shapes claim no branch twice: a ClickUp id has letters among its
digits, a custom id has capitals, and an issue number has neither. A branch like
`cleanup-logging`, `oauth2-login` or `<nickname>/cleanup-logging` carries none — the
team's convention names a branch without a task after its author — and that is an
answer, not a gap: nothing is asked, and the merge request goes out without a task
reference, as the title section below describes.

With a ClickUp or custom id, read the task's name and its link with `clickup task
<TASK_ID>` called directly, whose output carries both. Not through the `clickup` skill:
its reading protocol stops and asks when ClickUp refuses an id, and this skill does not
ask. The link is the one ClickUp gives for the task.

An issue number names an issue of the project the merge request is opened in, unless the
project's `CLAUDE.md` says otherwise. Some teams keep the code in one project of a group
and the issues in another, a workspace project beside the code, and then the code
project's `CLAUDE.md` carries one line, `Issues: <group>/<project>`, with the full path of
the project that holds the issues, as it stands in that project's address. Read the file
for that line before reading the issue; without it the issue is looked for in the current
project and nowhere else, because a bare number matches an issue in every project of the
group that has reached it, and the first match is not the task. Then read the issue's
title with `glab issue view <iid> -F json`, from this clone, which `glab` is already
pointed at, adding `-R <group>/<project>` when the `Issues:` line names another project;
the JSON carries the title as `title` and the issue's address as `web_url`.

When the task cannot be read — no CLI, no token, or ClickUp answers that it does not know
the id — nothing is asked either. The title is worded from the diff, as the title section
describes, and the link is built from the id: `https://app.clickup.com/t/{TASK_ID}` for a
ClickUp id, and for a custom id `https://app.clickup.com/t/<workspace_id>/{TASK_ID}`, with
the workspace number taken from the project's `CLAUDE.md`. A custom id with no workspace
number anywhere gets no link and no `Task:` line, because a link without that number
opens nothing. Each of these leaves one line in the final message saying why. ClickUp
answers an unknown id and a task in a workspace the token cannot see with the same 401,
so the line for a refused id names both causes — a typo in the branch name, or a task
outside the token's workspaces — and asks the developer to check which; a missing
workspace number is named as the reason the `Task:` line is absent.

An issue `glab` cannot read answers `404 Not Found`, and that answer names no cause: the
number has no issue in the project asked, or, with `-R`, the path on the `Issues:` line
is wrong or the token cannot see that project. The title is worded from the diff as for
an unread ClickUp task, and the description carries no `Closes` line, because a closing
reference to an issue that is not there closes nothing today and, once the issue turns
out to live in another project, points at whatever issue of this project gets that
number next. The final message says in one line that issue `#<iid>` was not found in the
project asked, names that project, and says that when the issue lives in another project
of the group, the line `Issues: <group>/<project>` in `CLAUDE.md` is what tells this
skill where to look.

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
into English — not a summary of the commits, and not shortened to fit a length. For a
GitLab issue the id is written the way GitLab names an issue, `#<iid>`, so the title
reads `#42: Meter readings import`; GitLab turns that into a link to the issue wherever
the title is shown, which a bare `42:` would not be. When the task has an id but its name
could not be read, the part after the colon states what the change does, worded from the
diff, in English. Without an id the title is the subject of the branch's own last commit
that is not a merge, exactly as written:

```sh
git fetch origin
git log -1 --first-parent --no-merges --format=%s "origin/<target>..HEAD"
```

`origin/<target>` after the fetch, because the local `<target>` may be stale or absent,
and `--first-parent`, because commits that came in with a merge of `<target>` belong to
colleagues and must never name this branch.

A draft is asked for with `--draft` on `glab mr create`, and the title stays exactly as
above. `glab` puts `Draft:` in front of the title itself when the flag is passed, so a
title that already carries the prefix arrives as `Draft: Draft: …`, and the notification
about it has gone to the project's members before anyone can fix the title.

Description: one line with the task, a second line when the branch has a blocker, and
empty when there is neither a task id nor a blocker — however many commits and files the
branch has.

```
Task: <task link>
Blocker: !<iid>
```

`<task link>` is the link the task reference section produced. For a GitLab issue the
first line is not a link but GitLab's own closing reference, `Closes #<iid>` when the
issue is in the project the merge request is opened in, and `Closes
<group>/<project>#<iid>` when the `Issues:` line put it in another project, with the path
exactly as that line gives it. GitLab reads the word and closes the issue when the merge
request is merged, which is why the issue is named this way rather than by its address,
and a reference without the project path can only close an issue of the project the merge
request is in. Without a task id, or without a link or a readable issue for it, there is
no `Task:` or `Closes` line, and the description is the `Blocker:` line alone or empty. No
summary, no test plan, no checklist, no list of files. The reviewer reads the diff and the
task; the description points at them.

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

Then print the link, the title, the target branch, the blocker when there is one and the
line about an unread task when there is one, in the developer's language like everything
else this skill says to them.

## Never

- Never force-push. If the branch has diverged, say so and let the developer decide.
- Never a merge request from an unpushed branch — push first, and if the push fails,
  stop and report the failure rather than creating something that points at nothing.
- Never merge it yourself.
