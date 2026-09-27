---
name: create-mr
description: "Turn a committed branch into a merge request in GitLab through the glab CLI: push it, write the title and description from the commits, and give back the link. Trigger on «создай MR», «оформи мерж реквест», «запушь и создай MR», «на ревью», create MR, merge request, open a PR. Expects the work to be committed already — committing is the commit skill, and reviewing somebody else's MR is review-mr."
compatibility: "Needs git and `glab` authenticated against your GitLab instance."
metadata:
  source: "https://github.com/TechTechWizard/skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Grep Glob Bash
---

# Create a merge request

Everything said to the developer is in the language they are speaking, from the first
line to the last: a stop on an uncommitted file, a question about the task, a refusal, a
failed push and the final link all follow the same rule. The stops matter most here,
because that is when the developer has to decide what goes into a client's repository,
and a question they have to translate first is the one most easily misread. The title and
the description of the merge request stay in English, because the reviewer may not share
that language.

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

From the branch name, `{TASK_ID}-{description}` → the first segment. When the branch
carries no id, ask for the task link rather than inventing a reference.

## Title and description

Title: `{TASK_ID}: {what it does}`, imperative, at most 72 characters.

A draft is asked for with `--draft` on `glab mr create`, and the title stays exactly as
above. `glab` puts `Draft:` in front of the title itself when the flag is passed, so a
title that already carries the prefix arrives as `Draft: Draft: …`, and the notification
about it has gone to the project's members before anyone can fix the title.

Description, and nothing beyond these three parts:

```
<one or two sentences: what this merge request is for>

## Summary
- <change>
- <change>

Refs: https://app.clickup.com/t/{TASK_ID}
```

No test plan, no checklist, no list of files. The reviewer reads the diff; the
description exists to tell them what they are looking at and why.

Those three parts are the whole description, so nothing is appended after `Refs:` — no
"Generated with" line, no co-author trailer, no emoji. Some hosts tell the session by
default to end every pull request description with such a line; that default is written
for the host's own pull requests, and it does not reach a description whose shape this
skill fixes. A merge request on a client project is read by the customer, and whether the
customer is told which tools wrote the code is the company's decision, not a line a host
adds by habit.

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

Use a HEREDOC for the body, or the formatting arrives mangled. `--yes` is there because
`glab mr create` asks "What's next?" after the title and description are set, even
when both were passed on the command line; in a terminal that is one keypress, in a
session with nobody at the keyboard it hangs the run. With the title and the
description given, that confirmation is the only prompt left, so the flag skips
nothing the skill wanted asked. For a draft, `--draft` joins this same command, with the
title unchanged.

Then print the link, the title and the target branch, in the developer's language like
everything else this skill says to them.

## Never

- Never force-push. If the branch has diverged, say so and let the developer decide.
- Never a merge request from an unpushed branch — push first, and if the push fails,
  stop and report the failure rather than creating something that points at nothing.
- Never merge it yourself.
