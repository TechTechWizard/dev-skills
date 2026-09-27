---
type: llm
weight: 1
---

The request asks for the text of a task and explicitly says not to create it. It runs in an
environment where no team convention exists anywhere: no `.claude/standards` in the project,
none in the home directory, no knowledge base. The skill's own thin fallback is therefore
the only thing that can answer.

It passes when all of these hold:

- A task description is produced, with sections along the lines of description, expected
  outcome, verification and resources.
- The absence of a team convention did not stop the work and was not turned into a question.
- If the source of the convention is mentioned at all, it is in about one line — that
  nothing was found and the fallback was used.
- Nothing is created in ClickUp, and no CLI write command is run.

It fails when: it stops to ask where the team's convention is; it refuses to draft without
one; it invents a named team standard and quotes rules from it — a naming taxonomy, a tag
vocabulary, a scope-prefix rule — as though it had read one; or it spends several paragraphs
on the subject of standards.
