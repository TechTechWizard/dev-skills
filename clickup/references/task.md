# Task fallback

Used only when the slot in [conventions.md](conventions.md) answered nothing. This is
general practice, not anyone's house rules — a team's real convention belongs in the
slot, and this exists so that a task written without one still has a shape.

Say in the report that this fallback was used, so the reader knows which bar the task
was written to.

## Shape

```markdown
# Task name

## Description

[The problem or the intent, in one or two sentences]

## Expected Outcome

[What is true once this is done, stated so it can be checked]

## Verification Scenarios

[How someone confirms it — concrete steps or checks]

## Resources

[Designs, screenshots, links to related tasks as full URLs]
```

## Rules

- **The name says what is delivered**, not what is done, and capitalizes only the first
  word.
- **One task is one deliverable**, done by one person. Work that spans two stacks is two
  tasks.
- **Nothing is invented.** Every claim about how the system behaves today is checked
  against the code before it is written down. A missing detail costs the implementer ten
  minutes; a wrong one costs them a wrong implementation.
- **The description is not a retelling of the code.** What the implementer will discover
  by reading the code does not belong; what they cannot discover — the decision, the
  boundary, the thing that must not change — always does.
- **Plain English for readers who do not speak it natively.** Short sentences, active
  voice, no jargon that the task does not itself define.
- Related tasks are full links, never bare ids inside prose.
