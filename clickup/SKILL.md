---
name: clickup
description: "Reads and writes ClickUp tasks through the clickup CLI: prepares a task for grilling (card, comments, linked tasks, statement in the developer's own words, list of unknowns), creates tasks and bug reports to the team's own convention, puts estimates and comments on tasks. Use whenever the user gives a ClickUp task id or app.clickup.com/t/ URL, or says «прочитай задачу», «что в таске», «подготовь к грилю», «заведи таску», «багрепорт», «поставь оценку», «напиши коммент в таску» — even when ClickUp is never named and even when the request looks like a one-liner."
compatibility: "Needs the `clickup` CLI from the claude-work-tools repository and a personal ClickUp API token; the skill offers to install the CLI on first use."
metadata:
  source: "https://github.com/TechTechWizard/skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Write Grep Glob Bash
---

# ClickUp

The agent's hands in ClickUp. What makes this worth a skill rather than plain CLI calls is
that the API fails silently in several places — markdown in comments, tag names, mention
chips, estimates in the wrong unit — and that the text going into a task follows a
convention this skill deliberately does not carry.

Two languages are in play, and they are decided separately. What goes into ClickUp — the
name, the description, a comment — is written in the language the convention asks for.
What is said to the developer — a draft shown for approval, a question, a line saying what
happens next, the final report — is in the language they are speaking, a Russian request
getting Russian answers from the first line to the last. The protocols and conventions
this skill reads are in English, and without the rule the answer drifts into the language
of the last document read rather than the language of the person reading it.

## Tool

Everything goes through the `clickup` command. `clickup --help` lists every command, and
the README of the claude-work-tools repository documents the traps; read the relevant part
before a write, because the API returns 200 on most mistakes and the damage shows up only
in the UI.

**The command is not part of this skill and may not be installed.** A skill cannot carry
executables, so the CLI arrives from its own repository. If the shell answers
`command not found: clickup`, or a call fails for want of a token, go to
`protocols/setup.md` — that is an expected first run, not a broken installation.

**Finding a list id**: `clickup shared` prints every folder shared with this token and the
lists inside it. Start there. `spaces`, `folders` and `lists` need a space id, which a
member who reaches projects through shared folders can never obtain.

Reading (`task`, `task --markdown`, `comments`, `tasks`, `my-tasks`) changes nothing — run it
freely. Writing (`create`, `update`, `comment`, `attach`, `tag`) is seen by the manager and
often by the client. Show the text to the user before posting and wait, unless they asked
to post directly — with a word that says so («сразу», «без черновика», post it now), not
with a request that merely looks complete; a wrong comment cannot be unsent from the
reader's notification.

## Where the conventions come from

The naming rule, the description style and the shape of a bug report are the team's, not
this skill's, and they are looked up rather than shipped:
list `<project>/.claude/standards/`, then `~/.claude/standards/`, and open what is there
about writing a task or a defect. Then a knowledge base over MCP, then a thin fallback
here. The full rule, including what to say when nothing answers, is in
`references/conventions.md`.

## Which protocol

Decide by what the user needs, not by the words they used:

- **Understand a task before working on it** (grill prep, «что там», «разберись») →
  `protocols/read-task.md`. Read-only.
- **Create a task or a bug report** → `protocols/create.md`, which reads whatever the slot
  holds for the kind being written. Work we will do ourselves is a task; something that behaves wrongly is a
  bug, and the two are written differently.
- **Estimate or comment on an existing task** → no protocol; the rules below and the CLI
  README are enough.
- **The `clickup` command is missing, or there is no token** → `protocols/setup.md`. Ask
  once, install, verify, then return to what was actually asked.

Read the protocol before acting.

## Rules that hold across protocols

- **Nothing is invented.** Every fact written into a task is verified against the code or
  the task's own comments. A missing detail makes the implementer read the code; a wrong
  one makes them trust the task instead.
- **Related tasks are full links** `https://app.clickup.com/t/<id>`, never bare ids in
  prose and never ClickUp mention chips — a chip renders as an empty string through the API
  and in exports.
- **Per-project values come from the project's `CLAUDE.md`**: list ids, tag names, glossary
  location. Look there first (`Grep` for `ClickUp`). If a value is missing, stop and ask —
  do not guess. ClickUp accepts any tag name and silently creates a new tag.
- **Estimates are hours.** `update --time-estimate 1.5` means ninety minutes. Convert
  minutes before passing them; the CLI does the millisecond conversion itself.
- **`clickup create` assigns the creator.** The CLI puts the token owner into `assignees`
  on every create; `clickup update <id> --unassign me` undoes it.
- **Verify after writing.** After `create` or `update`, read the task back with
  `clickup task <id>` and confirm the name, description, estimate and tags landed as
  intended. After `comment`, read `clickup comments <id>` and check the markdown rendered
  (no literal `**` or backticks). Fix before reporting done.

## Report

End with what was written and where: the task link, the fields set, which convention source
answered, and anything skipped with the reason (a tag not set because the project has no tag
names recorded). The user should not need to open ClickUp to know what happened.

## Never

- Never invent an identifier. A list id, a task id, a tag name or an assignee that did
  not come from a command's output or from the project's `CLAUDE.md` is a guess, and
  ClickUp accepts guesses silently — an unknown tag name creates a new tag, a request
  filed in the wrong list is never seen.
- Never post without showing the text first, unless the user asked to post directly in
  so many words. A complete request is not that word: it is what makes the draft worth
  reading. A wrong comment cannot be unsent from the reader's notification.
- Never delete a task somebody else created, and never delete one without saying so.
