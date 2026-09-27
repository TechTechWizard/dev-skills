---
name: quick-edit
description: "A small change the developer is watching: fix a bug in this file, rename it, add the field, adjust the copy. Reads the team standard for the touched stack, keeps the change surgical, runs the tests that already cover it, and answers with what the diff does not say. Trigger on «поправь», «почини», «переименуй», «добавь», «убери», «исправь», fix, rename, tweak — and on any change small enough that nobody will review it separately. NOT for a prepared task from the tracker: that is implement-task, which runs on its own and hands over a report."
compatibility: "Needs git. Written for Claude Code; the standards lookup reads ~/.claude/standards/."
metadata:
  source: "https://github.com/TechTechWizard/skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
allowed-tools: Read Write Edit Grep Glob Bash
---

# Quick edit

## What this is for

The developer asked for a change and is looking at the result right now. There is no
task to interpret, no report to write, and nobody downstream who needs evidence. What
this skill adds over just editing the file is that the team's conventions still apply
to a two-line change.

**If the request is a prepared task** — a tracker id, a statement with acceptance
criteria, anything that will be reviewed by someone else — stop and use
`implement-task` instead. Say which one you are using in a single clause, so the
developer can redirect you before the work rather than after.

## How

1. **The standard for the touched stack**, by the lookup in
   [standards.md](references/standards.md): list `<project>/.claude/standards/`, then
   `~/.claude/standards/`, and find what is in there about the stack you are editing —
   a document, or a directory of documents, whichever the developer put in the folder.
   Then a knowledge base over MCP, then the fallback here. Before the edit, three things
   in this order:
   - **Name the documents in a message, before you open them**: one line of text to
     the developer, `Стандарт: <full path>, <full path>`. For a change to code the
     stack's code-style document is always on it, because every line you write is
     subject to it; add architecture, testing or other documents when the change
     touches what they cover — a new class, an endpoint, a test. Write the line out
     rather than settling it in your reasoning: the developer sees your messages, not
     your thinking, and a choice of documents nobody can see is one nobody can correct
     while it still matters.
   - **Read them with the Read tool.** A short document whole; a long one by its
     headings (`grep -n '^#'` is its table of contents), reading whole every section
     whose heading covers the change. A keyword grep over the document is not reading
     it, before the edit or after: it returns the lines containing the words you already
     had in mind and hides the rule you did not think to look for, which is the one the
     standard exists to give you.
   - **Say what the reading found**: the rule that governs this change, or that the
     document has none about it — «правила про это нет». The same line goes into the
     answer at the end, so the developer sees which bar the change was held to.

   Skip this entirely for a change that no standard can have an opinion about — a typo
   in a comment, a version bump — and say that you skipped it.

2. **Surgical.** Touch what the request names and nothing adjacent. Improving code you
   happened to read is the most common way a two-line change becomes a review.

3. **Reuse before writing.** If the codebase already has this, use it. If the language
   or framework already has it, use that.

4. **Tests that already cover it.** Run them when they exist and are cheap to run; say
   what happened. Do not write new tests here — a change that needs new tests is a
   task, and belongs to `implement-task`.

   Cheap means the environment is already there: the runtime on the machine, the
   dependencies installed, the project's own container already up. Pulling an image,
   starting a container or creating a network to run a test or a syntax check is not
   cheap, however short the command looks — a running Docker daemon is the ability to
   build an environment, not an environment, and building one on the developer's
   machine is their decision. The image stays on their disk, and a container started
   from a clone of a client project can collide with the real project's compose
   network and volumes running next to it. So without the developer's word for it, no
   `docker`, `podman` or `docker compose` command at all, not even one to see whether
   the daemon is up. When nothing already present can run the check, say in the answer
   that it was not run and why, and give the exact command the developer can run
   themselves — `php -l <file>`, `php artisan test --filter=<TestClass>`, whatever the
   project's own check is.

5. **Back to the developer, and nothing they could read off the diff.** Name the file
   and the line so they have somewhere to jump, then only what the diff does not say:
   an edge case the change leaves open, a test you could not run and why, something
   nearby that now looks wrong. No headings, no report, no recap of the change — they
   are about to read it. When there is nothing beyond the diff, one line is the whole
   answer. Write it in the language the developer is speaking — a Russian request gets
   a Russian answer — while the code and the comments in it stay in English, as the
   codebase is.

   **A conclusion that changes nothing the developer does is either verified or left
   out.** "I read the framework and this case behaves as it did before" costs them a
   paragraph to learn that nothing happened. Either run the thing and report the
   result, or say nothing and let the unchanged behaviour stay unchanged. What survives
   this test is what would make them act differently: stop, look somewhere, decide
   something.

   This replaces a sentence count, which measured the wrong thing: four sentences of
   substance are not ceremony, and "Done, let me know if you want it committed" is
   ceremony in two. The count is kept elsewhere in this set of skills only where it bounds one
   field of a template, never a whole answer.

## Committing

Not part of this. When the developer wants the change committed they will say so, and
the `commit` skill owns the convention.

## Never

- Never improve code you happened to read. The request names what changes; everything
  adjacent stays as it is, however wrong it looks.
- Never write new tests here. A change that needs them is a task, and belongs to
  `implement-task`.
- Never commit. The developer is watching and commits when they are ready, with `commit`.
- Never pull an image, start a container or create a network to check a change unless
  the developer said so. What the check needs and does not have goes into the answer as
  a command for them to run.
