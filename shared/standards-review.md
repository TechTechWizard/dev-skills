# Checking a diff against each standard document

The built-in reviewers hunt bugs and do not look at the team's standards, and the session
that wrote or read the diff checks it against the standards from memory. By the time it
reviews, its context holds dozens of files, and the rules it read at the start have lost
their weight. This check gives each standard document a reviewer of its own whose context
holds nothing but that document and the diff, so a rule has nowhere to get lost.

It is one reviewer among the others, not a separate gate: its findings go through the same
filter and, in `implement-task`, the same two-cycle budget. It never asks the developer
anything.

## Which documents

The documents this run already chose by [standards.md](standards.md) — the ones named on
its `Стандарт:` line, each a file and never a folder. A slot entry that is a directory
contributes the documents inside it that were chosen for this diff, not every document it
holds: a mobile document is not checked against a web change. When the slot gave nothing
for this stack, there is nothing to run; say so in one line in the report and carry on.
The skill's own fallback checklist is not a standard document and gets no reviewer here.

## How to run it

1. Write the diff to a file once, so every reviewer reads the same bytes:
   `git diff <base>...<head> > "$(mktemp -d)/change.diff"` — for `implement-task` the base
   is where the task's branch started, for `review-mr` the merge request's target branch.
   Write down the path it prints.
2. Start one subagent per document, all at once, through the `Agent` tool, with the prompt
   below and nothing else: no task statement, no summary of the change, no other document.
   Anything you add is something for the rule to compete with.
3. Collect every answer before the filter runs. A reviewer that has not answered by the
   time the rest of the review is ready is named in the report as not having run; do not
   wait on it past that point.

The prompt, with the two paths filled in:

```
Read two files with the Read tool, both whole: the standard document <document path>
and the diff <diff path>. Read nothing else.

Find every place where a line the diff adds or changes breaks a rule written in the
document. Report only what the document itself states. Bugs, style you would prefer
and rules from anywhere else are out of scope.

For each violation, one block:
- where: <file>:<line in the new version>
- rule: "<the rule, quoted word for word from the document>"
- why: <one sentence: what in the diff breaks it>

If nothing breaks a rule, answer exactly: NO VIOLATIONS.
```

**Outside Claude Code**, where there is no `Agent` tool, run the same check yourself, one
document at a time: open the document with the Read tool right before reading the diff
against it, and say in the report that the per-document reviewers ran in the main session.
A check that quietly did not happen reads exactly like one that found nothing.

## What happens to a finding

A finding is kept only when its quoted rule is really in the document: `grep -F` a
distinctive part of the quote in that file. A paraphrase or a rule from memory is dropped.

Then it goes through the filter the skill already has for every other reviewer:

- **The project's standard wins over the developer's.** A finding from a document in
  `~/.agents/standards/` whose rule a document in `<project>/.agents/standards/` replaces
  for the same subject is dropped. Before dropping it, open the project's document and
  find the rule that replaces it; a guess that the project "probably" disagrees is not a
  reason.
- **The task wins over a standard.** A finding against something the task statement
  explicitly asks for is not applied; it goes into the report as a conflict for the
  developer, with both the quoted rule and the line of the statement.
- **Outside the diff, out of scope.** A finding on a line the diff did not add or change
  is dropped.

What survives is reported like any other finding, with the quoted rule and the document's
full path, because a reader who disagrees has to be able to check the rule in one step.
