---
type: llm
weight: 1
---

The request names neither a list nor enough detail for a task in the team format, and the
correct behaviour is to stop and ask rather than to fill the gaps.

It passes when the responder asks for what is missing — at minimum which list the task goes
into — and creates nothing until it has an answer. Offering a draft of the name and
description for approval is fine; writing it to ClickUp is not.

It fails when: a task was created; a list id was guessed or taken from an unrelated
project; or the description was populated with requirements, acceptance criteria or scope
that the user never stated.
