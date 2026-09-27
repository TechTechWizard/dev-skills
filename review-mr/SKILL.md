---
name: review-mr
description: "Review somebody else's merge request: read the diff against the team checklist, hunt bugs with the built-in reviewers, and post the findings as comments on the merge request. Trigger on «сделай ревью», «посмотри MR», «проверь мерж реквест», «отревьюй», review this MR, code review — and on any GitLab merge-request URL, even with no other instruction. Read-only on the code: it describes fixes, it never applies them. Reviewing your own fresh work is part of implement-task instead."
compatibility: "Needs git and `glab` authenticated against your GitLab instance. Uses the built-in code-review and security-review skills where the host has them, and reviews the diff by hand where it does not."
metadata:
  source: "https://github.com/TechTechWizard/skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Grep Glob Bash Skill
---

# Code review

You are reading somebody else's work. You do not change it: a reviewer who edits the
code takes the decision away from its author and hides the disagreement.

## 1. The standard

Find the team's review standard and the standard for the touched stack, by the lookup
in [standards.md](references/standards.md): list `<project>/.claude/standards/`, then
`~/.claude/standards/`, and open what is there about reviewing and about the stack the
diff touches. Then a knowledge base over MCP. Open them before reading any of the diff. The fallback when nothing closer exists is
[review-checklist.md](references/review-checklist.md), which ships with this skill.
Read them with the Read tool — a short document whole, a long one by the sections its
headings say the diff touches. A keyword grep over a document only finds the rules you
already suspected the author broke; the finding worth posting is usually the rule you did
not know to look for.

Say in one line which source answered — the document, with its full path when the slot
entry is a directory. A review measured against a bar the author cannot see is an
argument waiting to happen, and a directory name does not show them the bar.

## 2. The diff, and only the diff

```sh
glab mr view <iid> --comments
git fetch origin <source-branch>
git diff <target>...<source-branch>
```

Review what changed. Code the author did not touch is not in scope, however wrong it
looks — if it matters, it is a separate task, and the report says so under its own
heading.

## 3. Hunt bugs with the built-in reviewers

Invoke the built-in `code-review` skill through the Skill tool on the merge request's
changes — fetch the source branch first, then pass the branch or commit range as the
target, **always at `high` effort** (`high <branch>`). Never rely on the skill's
sticky last-used level: it carries over from whatever was typed last for unrelated
reasons, and review depth has to be the same on every merge request.

**The developer's checkout does not move.** The review usually runs from the
developer's own clone, and the built-in reviewer reads the files of the branch it is
given; left to itself it may get them by `git checkout` of that branch in this very
clone, which leaves the developer on somebody else's branch after the review, and with
uncommitted work either carried across or blocking the switch. So, before invoking it:

```sh
git rev-parse HEAD; git branch --show-current; git status --porcelain
wt=$(mktemp -d) && git worktree add --detach "$wt" "<source-branch>" && echo "$wt"
```

The first line is the record to compare against afterwards. The second puts the source
branch into a worktree of its own; write down the path it prints, because a shell
variable does not survive into the next command. Then pass the target as the range plus
one sentence that names the worktree — `high <target>...<source-branch>; the branch is
checked out at <worktree path>, read its files there and do not run git checkout or git
switch in the current clone`. The whole argument reaches the reviewer as its review
target, so the sentence is read where it is needed; it is text, not a flag, and nothing
else about the call changes.

When the reviewer returns, run the first line again and compare. If the branch or the
commit moved, switch back to what was recorded (`git checkout <branch>`, or `git checkout
--detach <commit>` when there was no branch) and say in the report that the built-in
reviewer moved the checkout and it was restored; if the switch back fails, stop and tell
the developer exactly where the clone stands. Then `git worktree remove "<worktree
path>"`, which removes the directory as well. The same applies to `security-review`
below.

Two rules when using it here:

- **Never pass `--comment` or `--fix`.** Posting belongs to this skill and targets
  GitLab; `--comment` targets GitHub pull requests. And a reviewer does not change code.
- **Its findings are raw input, not the review.** Every one passes the checklist and
  the standard first. A finding that contradicts the standard or the task's stated
  scope is dropped or reframed, not forwarded.

When the diff touches authentication, authorization, parsing of untrusted input, file
uploads or secrets, also run the built-in `security-review` skill on the branch. Same
two rules; its findings land in the security category. Parsing of untrusted input
means a new parser, deserializer or raw-byte handling — code that decides what the
bytes mean. Adding or changing a standard validation rule on a request, or the usual
coercion of a route parameter, does not count: the framework already decides what the
bytes mean there, and a review that ran the security pass on every `max:255` would
run it on every merge request. This is the same line `implement-task` draws, so the
author's own run and this review reach the same decision on the same diff.

When the merge request implements a Figma mockup, pull the reference through the
official Figma MCP (`get_screenshot`, and `get_design_context` for tokens) and compare
the implementation against it. A visual deviation from the mockup is a finding like
any other.

**When a built-in reviewer is not there at all**, which is the normal state outside
Claude Code, do not skip this step — it is the bug-hunting half of the review. Read the
diff yourself against [review-checklist.md](references/review-checklist.md) at the depth
this step prescribes, and say in the report that the built-in reviewers were unavailable
and the hunt was manual. A review that quietly loses its bug-hunting pass reads exactly
like one that found no bugs.

## 4. Read it yourself, by the checklist

The built-in reviewers are good at correctness and blind to convention: architecture,
the team's idioms and the quality rules are entirely yours. Go through the checklist
categories — implementation, logic, error handling and logging, dependencies and
impact, security and privacy, performance, API usability, testing, readability — and
merge the tools' confirmed findings into the matching ones.

Quality rules worth checking explicitly, because they are invisible to a bug hunter:
unfinished screens carry stubs, unimplemented buttons say so to the user, stubs are
reusable rather than copied, unfinished code carries a clear `TODO:`, and new
functionality on a production product sits behind a feature flag.

## 5. Two artifacts, never one

The **report** goes to the person who asked for the review: summary, every finding,
checklist status. The **comments on the merge request** go to its author and are a much
smaller thing. Never paste the report into GitLab.

How to write and post the comments — the budget, what to cut, and the GitLab API
recipe for anchoring a comment to a line — is in
[protocols/gitlab-comments.md](protocols/gitlab-comments.md). Read it before posting,
not after.

## The report

```
## Summary
What the merge request does, and the verdict in one or two sentences.

## Findings

### Blocking
What must be fixed before this can merge. Each with file:line, what breaks, and when.

### Non-blocking
Worth changing, does not hold the merge.

### Out of scope
Defects this review found outside the diff. Named here, not commented on the merge
request, and worth their own task.

### Quality standards
Stubs, unfinished functionality, feature flags.

### Done well
One or two specific decisions that were right. Name the decision, not the person.

## Checklist
One line per category: clean, or the finding that broke it.
```

Write the report in the language the developer is speaking. The comments on the merge
request are in English regardless, because the author may not share that language.

## What a claim in the report rests on

Every statement about the repository — a file is missing, a test does not exist, a
route is not registered — rests on a command that ran and showed it. A command that
did not run shows nothing, and a shell error is the usual way a command does not run:
zsh refuses a glob that matches nothing before the command starts, so `ls compose*.yml`
answering `no matches found` says nothing about a `docker-compose.yml` sitting in the
same directory, and a `grep --include=*.md` the shell expanded for you never searched
at all. The reader takes "the repository has no compose file" as a fact about the
project and plans around it, which is why the wrong claim costs more than a missing one.

When a command errors, read the error as the shell's before reading it as the
repository's: rerun without the pattern (`ls docker-compose.yml`, `git ls-files
'*compose*'`, a quoted glob). If no command gives a clean answer, the report says
"could not verify" and what was tried, and "absent" stays out of it.

## Never

- Never leave the developer's clone on another branch or commit than the one the
  review started from. The review reads somebody else's branch; it does not move the
  person who asked for it onto that branch.
- Never edit the code under review. A reviewer who fixes the defect takes the decision
  away from the author and hides the disagreement; the finding says what is wrong and
  what would fix it.
- Never paste the report into GitLab. The report goes to whoever asked for the review;
  the comments on the merge request are a much smaller, separate artifact.
- Never pass `--comment` or `--fix` to the built-in reviewers. Posting belongs to this
  skill and targets GitLab, and a reviewer does not change code.
- Never forward a finding from a tool as your own before it has passed the checklist and
  the standard. A finding that contradicts either is dropped or reframed.
