---
name: review-mr
description: "Review somebody else's merge request: read the task it belongs to, check the diff against that task and the team checklist, hunt bugs with the built-in reviewers, and post the findings as comments on the merge request. Trigger on «сделай ревью», «посмотри MR», «проверь мерж реквест», «отревьюй», review this MR, code review — and on any GitLab merge-request URL, even with no other instruction. Read-only on the code: it describes fixes, it never applies them. Reviewing your own fresh work is part of implement-task instead."
compatibility: "Needs git and `glab` authenticated against your GitLab instance. Reads a ClickUp task through the clickup CLI when it is there and a GitLab issue through the same glab, and reviews without the task when neither can be read. Uses the built-in code-review and security-review skills and one subagent per standard document where the host has them, and does that work by hand where it does not."
metadata:
  source: "https://github.com/TechTechWizard/dev-skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Grep Glob Bash Skill Agent
---

# Code review

You are reading somebody else's work. You do not change it: a reviewer who edits the
code takes the decision away from its author and hides the disagreement.

## 1. The standard

Find the team's review standard and the standard for the touched stack, by the lookup
in [standards.md](references/standards.md): list `<project>/.agents/standards/`, then
`~/.agents/standards/`, and open what is there about reviewing and about the stack the
diff touches. Open them before reading any of the diff. The fallback when nothing closer exists is
[review-checklist.md](references/review-checklist.md), which ships with this skill.
Read them with the Read tool — a short document whole, a long one by the sections its
headings say the diff touches. A keyword grep over a document only finds the rules you
already suspected the author broke; the finding worth posting is usually the rule you did
not know to look for.

Say in one line which source answered — the document, with its full path when the slot
entry is a directory. A review measured against a bar the author cannot see is an
argument waiting to happen, and a directory name does not show them the bar.

## 2. The task, then the diff

```sh
glab mr view <iid> --comments
git fetch origin <source-branch>
git diff --stat <target>...<source-branch>
```

An empty diff is reported as empty and stops the review there, before the task is
looked up: there is nothing to hold against it.

Read the task the merge request belongs to before reading the diff. Clean code that
does something other than what the task asked passes every other check in this skill,
which is why the task is read first.

**Find it in exactly two places, in this order.** First, the merge request description,
where `create-mr` writes one line about the task. For a ClickUp task it is the `Task:`
line: `Task: https://app.clickup.com/t/<TASK_ID>` for a ClickUp id, `Task:
https://app.clickup.com/t/<workspace_id>/<TASK_ID>` for a custom id. A merge request
opened before that format carries the link on a `Refs:` line instead, and it reads the
same way. In every form the last path segment is the id. For a GitLab issue it is the
closing line: `Closes #<iid>` names an issue of the project the merge request is in, and
`Closes <group>/<project>#<iid>` names one in another project, by that project's full
path. GitLab accepts `Fixes` and `Resolves` in place of `Closes`, and so does this step,
because a line written by hand closes the issue just the same. A ClickUp link or an issue
reference elsewhere in the text is a related task, not this one. Second, the source
branch name, `{TASK_ID}-{description}`, read by the same rule `create-mr` uses, in the
same order. A custom id such as `ABC-123` carries a hyphen of its own and is taken whole:
capital letters, a hyphen, digits. Otherwise the id is the first segment when that
segment is a ClickUp id — at least seven lowercase letters and digits, starting with a
digit and with letters among them. Otherwise the first segment is the iid of a GitLab
issue when it is digits and nothing else and the segment after it is not digits alone,
which keeps `2026-10-16-cleanup` from reading as issue 2026; `1.2.0-hotfix` is not digits
at all. An issue number from the branch belongs to the project the merge request is in,
unless the project's `CLAUDE.md` carries the line `Issues: <group>/<project>` that
`create-mr` reads, and then to that project. A branch like `cleanup-logging`,
`oauth2-login` or `<username>/cleanup-logging` has no task. Not the title, not a search
for a similarly named task, not a guess from the diff.

**Read a ClickUp task with the `clickup` command**, as the `clickup` skill documents it:
`clickup task <id>` for the card with the task's name, `clickup task <id> --markdown` for
the description as stored, `clickup comments <id>` for the comments, nothing more. The comments are not optional: a clarification that narrowed or
widened the scope usually lives there, and it changes the task — the later word stands.
Only when the thread itself leaves open which word stands does the finding quote both
instead of picking one. Write down what the task says is to be done and how it is
verified — its verification scenarios when it has them — word for word, because the
findings quote them.

**Read a GitLab issue with `glab`**, from this clone, which already points at the project
the merge request is in: `glab issue view <iid> --comments` for the issue and its comments
together, with `-R <group>/<project>` added when the reference carries a project path,
and `glab issue view <iid> -F json` when a quote has to match the stored text, because
`description` there is the markdown as written and `--comments` adds the comments to it
as `Notes`. The comments count for the same reason as in ClickUp, and the later word
stands there too. The scenarios of an issue are usually its checkboxes — `- [ ]` lines
under a heading about acceptance, as issue templates write them — and every checkbox line
is a scenario, ticked or not: a tick is something somebody did on the issue, not evidence
about this diff.

**When the task cannot be read, the review goes on without it.** No link and no id, the
`clickup` command missing, no token, a token ClickUp rejects, an id it refuses — each is
one line in the report saying which. When ClickUp refuses the call, read its error for
which of the two it is; where the error does not say — the same 401 answers a wrong id
and a workspace the token cannot see — one `clickup my-tasks` tells the token from the
id, since it works with a good token. The review then continues in full, without the
task. The `clickup` skill's own answers to these states — its setup protocol, its stop
to ask for the right id — are for a session about the task, not for a review: do not
install the CLI, do not walk through its setup, and do not stop to ask for the link. The
developer reads the line and decides. For a GitLab issue the one answer `glab` gives is
`404 Not Found`, and the line says what that leaves open. With a bare number it means the
project the merge request is in has no issue with that number, and the line names the
project and says that when the issue lives in another project of the group, the
description is where to say so, as `Closes <group>/<project>#<iid>`. With a full
reference it means the path or the number is wrong, or the token cannot see that project.
The review does not look through the group's other projects for the number, because every
project that has reached it has an issue with it, and none of them is thereby the task.

Then the diff:

```sh
git diff <target>...<source-branch>
```

**Check the diff against what the task asked**, once you have read it:

- A scenario the diff does not carry out is a **blocking** finding that quotes the
  scenario from the task and says what is missing from the change. A scenario that
  needs a stand to observe is met when the code that implements it is in the diff; the
  review does not run the stand.
- Work the diff does that neither the task nor its comments ask for is a
  **non-blocking** finding: name it, and say that it belongs either in the task or in a
  task of its own. It may well be a fix the author found on the way, and that decision
  is the author's, not the review's. A defect inside that extra work is still a finding
  of its own, wherever its severity puts it.
- A diff that carries out every scenario gets no finding about the task at all.
- On the merge request, the unmet scenarios are one blocking comment of their own,
  separate from any blocker in the code: it lists them, each quoted, never a comment
  per scenario.
- A task that states nothing checkable — no scenarios, no expected result, a one-line
  name — is measured against what it does say, and the report line says the task gave
  nothing more to check against.

Review what changed. Code the author did not touch is not in scope, however wrong it
looks — if it matters, it is a separate task, and the report says so under its own
heading, unless the slot's report document classifies it otherwise (see «The report»).

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
  the standard first. A finding that contradicts the standard or a decision the task
  made is dropped or reframed, not forwarded. A defect in work beyond the task is not
  such a finding: it stays, as step 2 says.

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

## 4. Check it against each standard document

Run one subagent per standard document chosen in step 1, all at once, each given only the
diff and that one document, by [standards-review.md](references/standards-review.md). This
is not the same as reading the standard yourself in the next step: you will read the diff
with the checklist, the tools' findings and the merge request's discussion in your context,
and a rule from the standard competes with all of it. A reviewer that holds only the rule
and the code does not have that problem.

Its findings pass the same two rules as the built-in reviewers' — raw input, checked
against the standard and the scope before anything is forwarded — plus the quote check in
that file. What survives goes into the report with the rule quoted and the document's full
path; on the merge request it becomes a comment like any other finding.

## 5. Read it yourself, by the checklist

The built-in reviewers are good at correctness and blind to convention: architecture,
the team's idioms and the quality rules are entirely yours. Go through the checklist
categories — implementation, logic, error handling and logging, dependencies and
impact, security and privacy, performance, API usability, testing, readability — and
merge the tools' confirmed findings into the matching ones.

Quality rules worth checking explicitly, because they are invisible to a bug hunter:
unfinished screens carry stubs, unimplemented buttons say so to the user, stubs are
reusable rather than copied, unfinished code carries a clear `TODO:`, and new
functionality on a production product sits behind a feature flag.

## 6. Two artifacts, never one

The **report** goes to the person who asked for the review: summary, every finding,
checklist status, or whatever the slot's report document lays out instead. The
**comments on the merge request** go to its author and are a much smaller thing. Never
paste the report into GitLab.

How to write and post the comments — the budget, what to cut, and the GitLab API
recipe for anchoring a comment to a line — is in
[protocols/gitlab-comments.md](protocols/gitlab-comments.md). Read it before posting,
not after.

## The report

When the standards slot holds a document about how the result of a review is laid out
for whoever asked for it, found by the lookup in step 1 with the project's folder first,
the report follows that document in full and adds none of the sections it leaves out.
Its rules win as well: what sets the status and what counts as critical, code outside
the diff that breaks a task scenario included, even where step 2 would put that code out
of scope. The template below and this skill's own rules are the fallback for when there
is no such document, and for any subject the document says nothing about. Whatever the
format, the report keeps every line the steps above require of it, the line about the
task (its link, or why it was not read) among them; a field the document asks for that
this review has nothing to put in, such as a path to evidence the review never produced,
is left out rather than invented, and leaving it out never lowers a finding's class,
because the quote, the file:line and the command output the review did produce are the
finding's evidence; and a finding that no section of the document fits goes into the
section closest to it in meaning rather than being dropped. The comments on the merge
request stay as step 6 describes them.

```
## Summary
What the merge request does, and the verdict in one or two sentences.
Task: the link, checked against it — the issue's own address for a GitLab issue — or
one line: the link or id that was found, if any, and why it was not read.

## Findings

### Blocking
What must be fixed before this can merge. Each with file:line, what breaks, and when.
A task scenario the diff does not carry out, quoted from the task.

### Non-blocking
Worth changing, does not hold the merge. Work beyond what the task asked.

### Out of scope
Defects this review found outside the diff. Named here, not commented on the merge
request, and worth their own task.

### Quality standards
Stubs, unfinished functionality, feature flags.

### Team standards
One line per standard document checked in step 4: its full path and "no violations", or
each violation with file:line, the rule quoted word for word, and whether it is blocking.
A document whose reviewer did not run is named as such.

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

- Never invent the task's goal. With no task read, the report says why and the review
  runs in full without it — the standard, the built-in reviewers, the checklist. A goal
  reconstructed from the title or the diff measures the change against itself and
  always passes.
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
