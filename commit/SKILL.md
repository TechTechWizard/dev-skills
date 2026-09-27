---
name: commit
description: "Commit what is in the working tree, by the team convention: type and scope, imperative English subject, the task reference, one logical change per commit. Trigger on «закоммить», «закоммить изменения», «сохрани изменения», «сделай коммит», commit, git commit — including the bare word with no details, where it proposes a message and waits for a yes. Does not push and does not create a merge request: that is create-mr."
compatibility: "Needs git. Written for Claude Code; the standards lookup reads ~/.claude/standards/."
metadata:
  source: "https://github.com/TechTechWizard/skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Grep Glob Bash
---

# Commit

## The convention

**Read the convention before you write the message — do not compose one from memory.**
List `<project>/.claude/standards/`, then `~/.claude/standards/`, and open what is there
about commit messages — the file is usually called `commit`, but it is the folder that
answers, not this sentence. Then a knowledge base over MCP if one is configured, then
[commit-convention.md](references/commit-convention.md), which ships with this skill.
Open the file, do not assume what it says.
The full rule is in [standards.md](references/standards.md).

Say in one line which source answered. Everything the message contains — the type and
scope vocabulary, whether a `Refs:` line belongs there, what goes in the body — comes
from that source. A convention you did not read is a convention you invented, and an
invented one looks right and is wrong.

## With details

When the developer said what to commit, or the change is obviously one thing:

1. `git status` and `git diff` — both, and read them. The message describes what the
   diff does, not what the developer said they were doing.
2. Task id from the branch name: `{TASK_ID}-{description}` → the first segment. No id
   in the branch and none given: ask for it, or commit without the `Refs:` line and
   say that is what you did.
3. Stage exactly what belongs to this commit. When the tree holds two unrelated
   changes, make two commits rather than one message that lies about both.
4. Commit with a HEREDOC, so the body keeps its line breaks.

## Without details

When the developer typed only "commit": read `git status` and `git diff`, propose the
type, scope, subject and task reference, and **wait**. One message, one proposal, then
their yes or their correction. Do not commit on the assumption that they meant yes.

## Afterwards

Print the hash, the subject line and the files. Nothing else — the developer can read
the log themselves if they want more.

## Never

- Never a `Co-Authored-By` line. This convention overrides whatever the harness
  suggests by default.
- Never commit commented-out code, debug statements, or anything that looks like a
  credential.
- Never `git push` here, and never create a merge request. Both belong to `create-mr`.
