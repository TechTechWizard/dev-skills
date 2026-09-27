# Where the conventions come from

Writing a task or a bug report into ClickUp follows the team's own convention, and this
skill does not carry it. This file says where to look and what to do when there is
nothing to find. Read it once per session, not once per step. Filling the slot is a human
job and is described in the README of the skills repository.

## Where to look

**The slot is a directory, and what is in it is the convention.** This file declares no
list of expected names: the listing is the truth, and a convention the team wrote
yesterday shows up by someone putting a file in the folder.

Two folders, in this order:

1. **`<project>/.claude/standards/`** — the project's own. A client project with its own
   way of naming tasks overrides everything else, which is the point of looking here
   first.
2. **`~/.claude/standards/`** — the developer's own.

For the same subject the project's folder wins and the lookup stops there. What lies
inside can be a document, a symbolic link to one, or a symbolic link to a directory of
them — all three read the same way.

List the folder with something that follows links — `ls -L <folder>`, `find -L <folder>
-name '*.md'`, or the read tool on the folder itself. Every entry is usually a symbolic
link, and file-search tools built on ripgrep skip links unless told to follow them:
OpenCode's `glob` answers "No files found" for a full slot, and the session then writes to
the fallback believing there is no convention.

When neither folder says anything about writing a task or a defect, and a company
knowledge base is configured over MCP, search that. Last comes the fallback shipped with
this skill: `task.md` and `bug.md` next to this file. They are general practice rather
than anyone's house rules, deliberately thin, so that somebody with none of the above
still writes to a stated shape instead of to none.

## What to open

A task and a bug are written differently, so open the one that matches what is being
written rather than both. Decide from the names in the folder: `task` and `bug` are the
usual ones, and a folder that names them otherwise is still the answer — this file is not
a list of what must be there.

## Say which source answered, and what to do when none does

One line, out loud, once, naming the file rather than the folder — "convention from the
project", "convention from `~/.claude/standards/task.md`", "nothing in the slot about
writing tasks, working to the skill's fallback" — and carry on. A
missing convention never stops the work, and it never becomes a question to the user
either: they know what they have installed.

Put the same line in the report, because a reader judging the task needs to know which
shape it was written to.

## When a convention contradicts the request

The request wins, always. A convention is how the team writes tasks; the request is what
this particular task is. Say that the two disagree — that is a decision for a person,
not for the session — and never quietly bend the request to fit a rule.
