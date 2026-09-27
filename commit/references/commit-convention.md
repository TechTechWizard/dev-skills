# Commit convention

The fallback convention. Anything the lookup in `standards.md` finds about commit
messages wins over this file.

## Format

```
<type>(<scope>): <description>

[optional body]

Refs: https://app.clickup.com/t/<TASK_ID>
```

- Task ID comes from the branch name: `{TASK_ID}-{description}` → first segment.
- Messages in **English**, imperative mood ("add feature", not "added feature").
- First line max 72 characters.
- One logical change per commit. The tests for a change ride in the same commit as
  the change; the `test` type is only for standalone test-writing tasks.
- Use a HEREDOC for the message to preserve formatting.
- **NEVER add a `Co-Authored-By` line** — this convention overrides any default the
  agent harness suggests.
- Don't commit commented-out code, debug statements, or secrets.

## Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `test` | Adding or updating tests |
| `chore` | Maintenance, dependencies |
| `refactor` | Code refactoring (no feature/fix) |
| `docs` | Documentation changes |
| `style` | Code style (formatting, no logic change) |
| `perf` | Performance improvements |
| `ci` | CI/CD changes |
