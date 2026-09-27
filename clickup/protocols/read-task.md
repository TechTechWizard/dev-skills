# Read Task

## When to apply

User asks to read a ClickUp task before starting work on it: to understand what is asked,
to prepare a statement for grilling, to find what has already been clarified in comments,
or to see how the task relates to others. Also the first step whenever a task id or URL is
given with «прочитай», «что там», «разберись», «подготовь к грилю».

## Steps

1. **Read the task itself.** `clickup task <id>` for the card (status, assignees,
   estimate, tracked time, tags), then `clickup task <id> --markdown` for the
   description exactly as stored. Do not paraphrase yet.
   If the call fails with `401 {"err":"Team not authorized","ECODE":"OAUTH_027"}`, the id is
   wrong or the task lives in a workspace the token cannot see — ClickUp returns the same
   error for both, so it cannot be told apart from outside. Run `clickup my-tasks` once: if it
   works, the token is fine and the id is the problem. Then stop and ask for the correct id
   or full link. Do not look for a "similar" task and continue with it.
2. **Read the comments.** `clickup comments <id>`. On most projects the
   manager's clarifications arrive as comments, not as edits to the description — a
   question already answered there must not be asked again in the grill.
3. **Follow the links.** Every `https://app.clickup.com/t/<id>` in the description or the
   comments is a related task: read its card the same way. Note which one has to be done
   first when the order is not written down — dependency order matters more than the
   apparent size of the work.
4. **Read the project glossary if the project has one** (a workbook, a `CONTEXT.md`, a
   spec folder named in the project's `CLAUDE.md`). Terms from the client's vocabulary
   that appear in the task are looked up there, not guessed from the code.
5. **Write the statement in one paragraph, in the developer's words**, not the task's:
   what changes for whom, what stays untouched, what depends on what. This paragraph is
   what goes into the grill; the raw description does not — on a raw description the grill
   sinks into nuance questions.
6. **List what is unknown.** Every term with no definition, every step that cannot be
   verified yet (a screen that does not exist, a stand that is not deployed), every
   conflict between the description and a comment. These are the questions for the
   manager, and they go out before code is written, not after.

## Result

```markdown
## <Task name> — https://app.clickup.com/t/<id>

**Statement (own words):** [one paragraph]

**Already clarified in comments:** [date — who — what; or "nothing"]

**Depends on / blocks:** [full links, with the order if it had to be inferred and why]

**Unknown, to ask before starting:** [numbered list; each item says why the answer changes
the work]

**Card:** status, estimate, tracked, tags — as read, not as assumed.
```

## Rules

- **Nothing is inferred.** If the description says X and the code does Y, that is an
  item under *Unknown*, not a silent decision. If a term is undefined, it is an item under
  *Unknown*, not a guess from a similarly named class.
- **Every fact was read in this session, and can be pointed at.** A status, a date, a
  decision, the state of a document the task refers to — each comes from the card, a
  comment, a file opened or a command run during this preparation, and the result can
  say which. What the session carries from elsewhere — an earlier conversation, the
  project's memory, the developer's own words about the task — is not read; it is
  remembered, and a remembered status is the kind that has changed since. Such a fact
  goes under *Unknown* with the file or command that would settle it, or is left out.
  The reason is what the statement is for: the grill starts from it, and a decision
  named as still open when it was accepted last week sends the whole discussion the
  wrong way from the first minute.
- **Dates on everything taken from comments.** «Already agreed» without a date and an author
  is a claim, not a fact.
- **Do not estimate here.** The estimate comes after the grill, on the grilled statement;
  writing it is `clickup update <id> --time-estimate <hours>` and happens only
  when the user says so.
- **Do not change the task.** This protocol reads. A question for the manager is posted as a
  comment only when the user asks, and then per the mention rules in the CLI README, so the
  person is actually notified.

## Tools

- Bash: `clickup task <id>`, `task <id> --markdown`, `comments <id>`
- Read: the project's `CLAUDE.md` for the glossary location and tag names
