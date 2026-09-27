# Bug report fallback

Used only when the slot in [conventions.md](conventions.md) answered nothing. This is
general practice, not anyone's house rules.

A bug is not written like a task. **Every section is filled in**, because the reader is
reproducing something rather than building it, and the shortcut that makes a good task —
leaving out what the code already says — makes a useless bug report.

## Shape

```markdown
# Bug name

## Description

[What is observed]

## Expected Behavior

[What should happen instead]

## Steps to Reproduce

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Impact

[Who is affected and how badly]

## Screenshots/Logs

[Screenshots, error text, console or server logs]
```

## Rules

- **The name states the observed problem, not the fix**, and capitalizes only the first
  word.
- **Steps to Reproduce are steps somebody actually walked**, on a named environment with
  named data. Invented steps send the investigator down the wrong path.
- **Root-cause pointers belong here** — a `file:line`, the exception, the log excerpt.
  Unlike in a task, they are the point: a bug report exists to save investigation time.
- A section that cannot be filled yet is left present and marked as unknown, rather than
  dropped.
- Related tasks are full links, never bare ids inside prose.
