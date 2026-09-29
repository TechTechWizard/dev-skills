# Where the standards come from

Every skill in this set that touches code reads the team's standard for what it is about
to touch. This file says where to look, what to open and what to do when there is nothing
to find. Read it once per session, not once per step. Filling the slot is a human job and
is described in the README of the skills repository.

## Where to look

**The slot is a directory, and what is in it is the standard.** There is no list of
expected names anywhere in this skill, deliberately: the listing is the truth, and a
direction the team documented yesterday shows up by someone putting a file in the folder,
not by a skill learning its name first.

Two folders, in this order:

1. **`<project>/.agents/standards/`** — the project's own, committed into the repository.
   A client project with its own code guide overrides everything else, which is the point
   of looking here first.
2. **`~/.agents/standards/`** — the developer's own.

For the same subject the project's folder wins and the lookup stops there. Subjects the
project says nothing about still come from the developer's folder: a project that ships
its own CSS guide has not thereby cancelled the team's commit convention.

What lies inside is up to the person who set it up. It can be a document, a symbolic link
to a document, or a symbolic link to a whole directory of documents in a checkout they
already have. All three read the same way — open the file, or list the directory and open
what is in it.

**List the folder with something that follows links.** Usually every entry in the slot is
a symbolic link, and file-search tools built on ripgrep skip links unless told to follow
them: OpenCode's `glob` answers "No files found" for a slot that holds a dozen documents,
and a session that takes that answer at its word works to the fallback while believing the
slot is empty. `ls -L <folder>` lists the entries, `find -L <folder> -name '*.md'` lists
the documents inside linked directories, and the read tool pointed at the folder itself
shows its entries as well. An empty answer from a pattern search is not evidence that the
folder is empty; only one of these listings is.

When neither folder answers for the stack being touched, the fallback that ships with this
skill answers, if there is one. It is general practice rather than anyone's house rules,
and its only job is that a developer with nothing set up still works to a stated bar
instead of to nothing.

## What to open

Read only what the work actually touches, and decide that from the names you see. A name
that matches the stack being edited, a name that matches the activity being performed —
that is the whole of the rule. Everything else in the folder belongs to work this session
is not doing.

A directory entry is read the same way: list it, open the documents whose names match, and
leave the rest. Documentation repositories nest their documents (`common/`, `nextjs/`,
`react-native/`) and the nesting says what a document is for, so a mobile document is not
opened for a web change. An `index.md` in such a repository is usually an introduction
rather than a table of contents — opening it costs a read and answers nothing, and having
opened it is not having read the standard.

**Write the choice down before the edit.** One line of text in a message — not a decision
in your reasoning, which nobody but you can see — naming the documents you are about to
read, each by its full path. For a change to code, the document about how code is written
in that stack — its code style, naming, formatting — is on that line every time, because
every line of the change is subject to it; architecture, testing or best-practice documents
join it when the change touches what they are about, a new class or endpoint, a test. The
line is there so that a document left out is visible before the edit, to you and to the
reader, rather than discovered in review.

**Reading is opening the document, not searching it.** A search for words returns the lines
that contain the words you already had in mind, so it can only confirm what you expected the
standard to say; the rule the standard exists to give you is the one you did not think of,
and it sits in a paragraph that contains none of your words. A grep with context lines
around its matches looks like a section, but it is a section cut to fit your guess — and
that holds whether it runs before the edit or after it. So:

- A document of a few hundred lines is opened with the Read tool and read whole.
- A longer one is navigated by its headings: `grep -n '^#' <document>` is its table of
  contents, and that is the one search that is navigation rather than reading. Pick every
  section whose heading covers what the change touches, and read each with the Read tool
  from its heading to the next heading of the same level. When no heading covers the
  change, read the general sections at the top, the part that applies to all code.

A search across a whole slot entry is worse still: it runs through every subdirectory at
once, so a mobile rule matches on a web change and arrives without the heading that would
have said whose rule it is.

## Say which source answered

One line, out loud, once, with the document and what reading it found: "standards from the
project, `.agents/standards/php.md`: request classes validate every string with a length
limit", "standard from `~/.agents/standards/frontend/<section>/<code-style>.md`,
section on components: правила про это нет", "nothing in the slot for this stack, working to
the skill's fallback". Put the same line in the answer or the handover report, because a
reader judging the result needs to know which bar it was measured against — and "the
document has no rule about this" is a finding too, one that tells the reader the choice in
the diff was yours.

Naming the file rather than the folder matters, and when the slot entry is a directory the
file is the document inside it: `~/.agents/standards/frontend/nextjs/<document>.md`, not
`~/.agents/standards/frontend/`. The line is a claim that a document was read, and a reader
checks it against the files the session actually opened; a folder that exists proves
nothing about what was read, a document that was only grepped was not read, and a checkout
nobody has pulled answers with last year's rules while looking entirely current.

## When there is nothing to find

Nothing stops. Say in one line that the slot holds nothing for this stack and carry on to
the fallback, or to plain good practice if there is no fallback. A missing standard never
becomes a question to the developer either: they know what they put in their own folder.

## When a standard contradicts the task

The task wins, always. A standard is how the team writes code; the task is what the
developer decided this change is. Record the contradiction in the report — that is a
decision for a person, not for the session — and never edit the task statement to fit a
rule.
