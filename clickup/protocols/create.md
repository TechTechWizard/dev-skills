# Create

One procedure for putting a task or a bug report into ClickUp. What differs between the
two is the text, and the text comes from the convention, not from here.

## When to apply

The user asks to create a task, a task description, or a bug report. Work we will do
ourselves is a **task**; something that behaves wrongly is a **bug**. Decide which one it
is before writing anything — the two are written differently, and the difference is in
the convention, not in this file.

## Steps

1. **Read the convention** for the kind being written, by the lookup in
   `../references/conventions.md`: what the slot holds about tasks for work we do, what
   it holds about defects for a bug.
   One line about which source answered, written out here, before the draft exists —
   not in the report after the item is created. The line tells whoever reads the
   transcript which shape the text was written to, and it is only useful while the
   text can still be changed; in an unattended run it is the only place the source
   appears before `clickup create` runs.

2. **Find where it goes.** The list id and the tag names come from the project's
   `CLAUDE.md` — grep it for `ClickUp`. If the user named the list, that wins. If neither
   is available, stop and ask; a task filed in the wrong list is never seen, and
   `clickup shared` prints the folders and lists this token can reach if you need the map.

3. **Verify before writing.** Every claim about how the code behaves today is checked
   against the code, including the claims the request itself makes — a route prefix, an
   enum value, a field name. Document reality; do not invent scope. If an essential
   detail is missing and cannot be established, ask one clarifying question before
   creating anything.

4. **Draft, then check the draft against the convention** before it is created. Fix what
   fails. Show the text to the user and wait, unless they asked to create directly — a
   wrong task cannot be unsent from the reader's notification. "Directly" is a word in
   the request — «сразу», «создавай сразу», «без черновика», create it now — and
   nothing else stands in for it. A request that names the list, the parent and the
   whole content is a complete request, not a permission to skip the draft: complete
   input is what makes the draft worth reading, and the item still lands in a list a
   manager watches, with a notification that has already gone out. When nobody can
   answer, the draft is the end of the run and nothing is created.

5. **Create it.**

   ```sh
   clickup create <list_id> "<name>"
   clickup update <task_id> -d "$(cat <file>)"
   ```

   Write the description from a file rather than inline: the CLI renders markdown into
   ClickUp rich text, and tables and code blocks survive that way.

6. **Fix the assignee.** `clickup create` puts the token owner into `assignees` on every
   create. When the item should have no assignee or a different one:

   ```sh
   clickup update <task_id> --unassign me [--assignee <their id>]
   ```

   Skipping this leaves the item sitting in the creator's list; say so in the report if
   it was skipped.

7. **Tag the layer.** `clickup tag <task_id> <tag>`, with a name taken from the project's
   `CLAUDE.md` and never guessed — tags are keyed by name, an unknown name does not fail,
   it silently creates a new tag nobody filters by. If the project records no tag names,
   skip the tag and say so in the report.

8. **Read it back.** `clickup task <id>` and confirm the name, description, assignees and
   tags landed as intended. The API returns 200 on most mistakes and the damage shows up
   only in the interface, so this step is not optional.

## Rules

- **One item per request.** A request naming several pieces of work produces one task,
  and the rest is said in words rather than generated. The exception is a request that
  spans two stacks, which the `task` convention splits into two — show both drafts before
  creating either.
- **Do not set an estimate** unless the user asked for one.
- **A wrong item can be removed.** `clickup delete <id>` deletes it, and ClickUp keeps
  deletions in the workspace Trash for thirty days. Use it to clean up after your own
  mistake — never on something somebody else created, and never without saying so.
