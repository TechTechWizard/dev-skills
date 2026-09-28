---
name: implement-task
description: "Take a prepared task and run it to 'ready for human review' on your own: code, self-review loop, self-fixes, verification, commits by the team convention, and an honest handover report. Use when the developer hands over a task whose analysis and grilling are already done — trigger on «реализуй задачу», «запускай в работу», «пили», «делай задачу», «бери таску», implement the task, run this task, even when the skill is never named and even right after a grill session ends. NOT for a small change the developer is watching — that is quick-edit. Does not analyse or grill the task, does not estimate it, and does not create the merge request."
compatibility: "Needs git. Written for Claude Code: it invokes the built-in code-review, security-review, simplify and run skills through the Skill tool, and degrades with a note in the handover when they are absent."
metadata:
  source: "https://github.com/TechTechWizard/skills"
  update: "npx skills update"
  standard: "https://agentskills.io/specification"
---

# Implement a task

The first text you write in a run is the intake message of Step 0, before any other
message and before any edit — also when every answer was given in advance.

## Role and boundaries

You finish the code; the developer owns the ideas. The task statement, the pre-analysis
and the grilling results are the developer's work and they are already done before this
skill starts. Downstream, the merge request is created by a separate tool.

**In scope:** writing the code, reviewing it yourself, fixing what the review finds,
verifying the result (tests always; live stand when the developer asked for it),
committing by the team convention, and handing over a report for human eyes.

**Out of scope — never do these:** analyzing or re-interpreting the task, grilling,
estimating, creating the MR, changing the task statement, improving adjacent code the
task does not touch. Surgical changes only.

**If the prepared context is missing — say so and stop.** Prepared context means: a
task statement that says what to do, what the expected result is, and how to verify
it (in any form, including the developer's own rewritten one), plus the analysis
results (and the grilling output, when the task was grilled). If any of that is
absent from the session and from the files the developer points to, stop. Do not
reconstruct the task yourself: that is the developer's step, not yours.

## Step 0 — Intake: the first thing you write

**The intake message is the first text of the run.** Before it you read what the intake
needs — the task statement and the files it points to, the project's `CLAUDE.md`,
`.claude/verify.md` if there is one, the code an ambiguity turns on — but you write
nothing else and edit nothing. Working the answers out in your reasoning is not the
intake: the developer reads your messages, not your thinking, so an intake that was only
decided is, from where they sit, an intake that never happened. Write it out as a
message, then go on. The
first thing a reader sees decides what they think is running: an intake message says
`implement-task`, a diff with no preamble says `quick-edit`. The message is also the
record of how you read the developer's answers, and the only moment they can correct a
misreading before it turns into code. A progress line written ahead of it ("reading the
standard now") is exactly where the intake gets lost: once the run is talking about the
work, a message about how the answers were read feels like a step already behind you,
and it surfaces, if at all, in the handover.

**Answers given in advance are the input to the intake, not a reason to skip it.** A
prompt that already says "no live stand, no questions until morning" makes the message
shorter and removes the wait; it does not remove the message. Those are the runs where
it matters most, because nobody is watching to catch a misread answer.

The message has a fixed shape, so that it cannot dissolve into the text around it:

```
Приёмка implement-task
1. Проверка на стенде: <да / нет → вариант 3, только тесты / вопрос> — <откуда: дано в промпте / в постановке / спрашиваю>
2. Неясности: <по строке на каждую: закрыто чем и на каком основании / вопрос>
<Жду ответа. | Ответы даны заранее — продолжаю без ожидания.>
```

Every pre-given answer appears on the line of the question it answers, mapped onto that
question's own options ("тесты не запускать" → option 3 of question 1; "ветка от
development" → question 2, closed by the prompt), so the developer can see each one was
understood. The heading line stays exactly as written in every language, because it is
what a reader or a watcher looks for; the rest follows the developer's language.

Ask everything up front in that single message, then do not ask again until the
handover. The verify.md exchange below — the developer picking an option and you asking
for the blanks you could not fill — counts as part of intake; the stop rules below are
the only other exception:

1. **Live-stand verification: yes or no?** A plain "no" means option 3 below.
   If the project has `.claude/verify.md`, skim it against the repo right here at
   intake — do the commands, paths and ports it names exist? — and raise any
   mismatch now, before a line of code is written; on "yes" you will follow it. If the file is missing, include in this same
   intake message, under "if yes": the template from [verify-template.md](references/verify-template.md)
   pre-filled with what you found in the repo yourself, and its three options to
   choose from. Do not make the developer invent the format. After the developer
   chooses option 1 or 2, you write the `.claude/verify.md` file yourself and ask
   only for the blanks you can neither discover in the repo nor create yourself —
   Step 4 does not start while those are missing. Choosing option 3 cancels live
   verification for this run: Step 4 runs tests only, and the handover says live
   verification was skipped by choice.
2. **Anything genuinely ambiguous in the prepared materials** — ask now, not mid-flow.
   Only questions the analysis and grill did not already answer.

   **Resolve before you ask.** A question the project already answers is not the
   developer's to answer: go and read. Its `CLAUDE.md`, the code around the change and
   the conventions visible in the history settle most of what
   feels ambiguous at first reading; the standards themselves are read in Step 1, after
   the intake. Say in the intake message what you closed this way
   and on what basis — one line each — so the developer can overrule a reading you got
   wrong. What survives is the genuine article: a product decision, a priority, access
   to something real, a trade-off with no right answer in the repository. Ask that, and
   only that.

## Step 1 — Standards

Find the team's standard for the stack this task touches, by the lookup in
[standards.md](references/standards.md): list `<project>/.claude/standards/` first, then
`~/.claude/standards/`, and find what is in those folders about this stack — a document,
or a directory whose document names say what each one covers. Then a knowledge base over
MCP if one is configured, then the fallback that ships with the skill. Before the first
line of code:

- **Name the documents in a message, before you open them**: one line of text,
  `Стандарт: <full path>, <full path>`. The stack's code-style document is always on it
  for a code change, because every line you write is subject to it; architecture,
  testing and the rest join it when the task touches what they cover. Write it out
  rather than settling it in your reasoning — the reader sees messages, not thinking —
  so a document missing from the line is visible now, not in review.
- **Read them with the Read tool** — a short document whole, a long one section by
  section from its headings (`grep -n '^#'` is the table of contents), every section
  whose heading covers what the task touches. A keyword grep over a document is not
  reading it: it returns the lines with the words you already expected and hides the rule
  you did not know to look for, and a standard you did not read is not a standard you
  followed.
- **Say what the reading found** — the rules that govern this task, or «правила про это
  нет» for a document that has none.

Repeat the documents and their findings in the handover: a reader judging the result
needs to know which bar it was measured against, and a directory name tells them which
entry was found, not what was read.

**Nothing found is not a stop.** Follow the conventions visible in the codebase and
record "no standard found" in the handover.

**When a standard conflicts with the prepared task statement** (say, a naming rule
against a name the task fixes), the statement wins — you never change the statement —
and the conflict is logged in the handover for the developer to settle.

## Step 2 — Code

- Surgical changes: touch only what the task requires. One exception: a pre-existing
  defect that blocks the task's own verification command (a broken test bootstrap,
  a build script that never worked) may be fixed — as a separate commit, named in
  the handover with proof it was broken before your change.
- Follow the minimal-code ladder before writing anything: does it need to exist
  at all → is it already in the codebase → is it in the stdlib → is it a native
  platform/framework feature → is it in an installed dependency → can it be one
  line → only then write minimal new code.
- If a minimal-code plugin is installed, invoke its skill (Skill tool) now, before
  the first line of code — implementation is the only activity where it belongs, so
  its session-wide default is expected to be off. If none is installed, apply the
  ladder yourself; the result must not differ.
- The ladder never overrides the task: when the statement explicitly asks for
  duplication or the "full" version of something, build exactly that and do not
  re-argue it — log the tension in the handover instead.
- Reuse existing solutions from the codebase; keep abstractions at the level the
  codebase already uses.
- Comments in English, explain "why" not "what"; unfinished edges marked `TODO:`.
- Write the tests the change needs, in the project's existing test style. If that
  style depends on generated artifacts (fixtures, snapshots) that cannot be generated
  in this environment, write them by hand and name them in the handover as the first
  thing a human must re-generate and verify.
- **When the task carries a Figma mockup** (a figma.com link, or a statement saying the
  work is by the mockup): invoke the `figma-design-to-code` skill on top of the official
  Figma MCP — `get_design_context` for structure and tokens, `get_screenshot` for the
  reference. The mockup is the source of truth for visuals, and the result is compared
  against the screenshot rather than against memory. Visual deviations are defects.
- **Once it compiles and the tests pass, run the built-in `simplify` skill** over the
  change. It only touches the diff, so the surgical rule holds. Review what it does as
  you would your own edit, and drop anything that contradicts the standard from Step 1.
  When it does not run — the host has no such skill, or you decided the diff gave it
  nothing to do — the handover's «Ревью» section says so with the reason, because a
  simplify pass that quietly did not happen reads exactly like one that found nothing
  to change, and the reader cannot tell a clean diff from an unexamined one.

## Step 3 — Self-review loop

One cycle = one review pass plus the fixes it caused; a pass closes only when the
reviewer's complete output is in, so findings arriving in batches from one pass are
one cycle. A review pass with zero findings ends the loop — no second cycle needed.
**Hard limit: two cycles.** If the
second cycle still leaves findings, stop and report them honestly in the handover —
do not spin a third time.

**Reviewer: the built-in `code-review` skill** — always. Effort `medium` by default;
**always `high` when the diff touches auth, permissions, money/billing, or personal
data** ("money" means any code computing amounts a customer pays or is owed). Never
rely on the sticky last-used level — pass the level explicitly every time. When the
work lives outside the session's cwd (a worktree, another checkout), pass the path or
branch explicitly and verify from the reviewer's own output that it reviewed the
intended repo before accepting anything. If the built-in skill is unavailable, cannot
target the diff (it reviewed a different repo or the session cwd instead), or its
report has not come back to your context by the time the cycle is otherwise ready to
close — do not sit waiting for it — review the diff yourself against
[review-checklist.md](references/review-checklist.md) at the level this rule
prescribes for the diff, and flag "built-in reviewer unavailable" in the handover. A
report that arrives after the manual pass counts as confirmation (or extra findings
for the current cycle), never as a new cycle.

The categories in [review-checklist.md](references/review-checklist.md) are the review criteria on every
path — for the built-in skill's findings and for your own review pass.

Every finding passes the standards filter before fixing: anything that contradicts
the standard from Step 1 or the task's stated
scope is dropped, not applied. Findings outside the reviewed diff are dropped too —
and a reviewer whose findings are all outside the diff has not actually reviewed it;
treat it as unavailable. A finding that sits on a line of your diff but whose fix
would change the behavior of code paths the task does not touch counts as out of
scope as well: escalate it in the handover, do not apply it.

**Additionally:** when the diff changes auth/authorization logic, parsing of
untrusted input (a new parser, deserializer, or raw-byte handling — standard
coercion of a route parameter with validation does not count), file uploads, or
secrets handling, run the built-in `security-review` skill on the branch — merely
adding a standard validation rule does not count. Its findings go through the same filter and the same fix loop, within the same
two-cycle budget — security-review does not grant an extra cycle.

## Step 4 — Verification

- **Watch it work, when there is something to watch.** For a change with observable
  behaviour, invoke the built-in `run` skill to bring the project up and confirm the
  change does what the task asked, not only that the tests are green. Skip it for a
  pure refactor, a config change or documentation — and say that you skipped it.
- **Tests always:** run the project's test suite for the touched area; the change is
  not done while tests fail. If the standard way to run tests is unavailable (no
  runtime, no dependencies installed), either run them in an environment that
  already exists — the project's own container that is already up, a virtual
  environment already installed — or put an honest "tests not run — no runtime
  available" into "НЕ проверено" with the exact command for the human to run.
  A running Docker daemon is not such an environment: it is the ability to build
  one, and building one is the developer's decision, not yours. The project's
  compose file carries the project name, the network and the volume names of the
  real project, which may well be running on this same machine next to the clone;
  a `docker compose up` from the clone, or a network and containers of your own
  with a fresh dependency install inside, collides with that — a subnet already
  taken, a volume reused — and the collision lands on the developer's data, not on
  the test run. Bring infrastructure up only when the developer said so for this
  run, in the prepared materials or at intake; when you can already see at intake
  that there is no way to run the tests without building one, ask there, in the
  same single message. Never install or start runtimes and daemons on the
  developer's machine for this, and never imply tests passed when they did not
  run. An honest "tests not run" does not block Steps 5–6: it goes first in
  "НЕ проверено" and the work proceeds to commit and handover.
- **Live stand — only if the developer said yes at intake:** follow the project's
  `.claude/verify.md` (stand address, test user, how to seed data). Verify with real
  requests — direct API calls for backend, Playwright for UI — against real data.
  Keep the evidence: the exact requests/steps and the responses, for the handover.
  You may fill and update `.claude/verify.md` yourself as you go: something you
  create during verification (a test user, seeded data) or discover (a working URL,
  an auth recipe) goes into the file — and every such change is listed explicitly
  in the handover.

## Step 5 — Commit

Commit yourself, by the convention in
[commit-convention.md](references/commit-convention.md) — or by whatever Step 1
found in the slot about commit messages, which wins over it. One logical change
per commit, messages in English, `Refs:` line with the ClickUp task URL, never a
`Co-Authored-By` line. Task-prep files (prepared context, developer notes) are never
committed — they describe the work, not the product, and in the repo they rot into
misleading documentation; one already tracked before the run is left untouched and
noted in the handover. A `.claude/verify.md` you created at intake is project config, not task
prep: commit it as its own `chore` commit placed before the task's commits, keeping
the task's `Refs:` line (the task is what brought the file into being). The MR
is not yours: leave a clean committed branch and stop there — pushing and creating
the MR belong to a separate tool.

## Step 6 — Handover report

The final message to the developer. This is what "then the human looks" runs on, so
it is short, honest and complete:

```
## Требует решения разработчика
[optional first section — only when stop rule 1 escalations exist: contradictions
between the task statement and the code, and out-of-scope defects the review
surfaced; one numbered point each. Omit the section entirely when there are none]

## Что сделано
[what changed and why this way — a few sentences, not a file list]
[one line with the minimal-code ladder outcome: what was reused, or why new code was needed]
[a tracked task-prep file left untouched is noted here, at the end]

## Проверено
[tests run + result; stand verification: exact requests/steps and what they returned]
[changes you made to .claude/verify.md — anything created or discovered during verification]
[when nothing executed, this section holds only the review results and says so in one line —
never pad it with the appearance of verification]

## НЕ проверено
[what was not verified and why — including "standards unavailable during this run" if it happened,
and "live verification skipped by the developer's choice" when option 3 was chosen at intake]

## Ревью
[which reviewer actually ran — canonical form: "встроенный code-review (уровень N)" / "ручной проход по review-checklist.md (за встроенного)"; combine the forms with "+" when cycles used different ones]
[simplify: ran, or skipped with the reason]
[findings fixed; findings remaining after 2 cycles, if any]

## Куда смотреть в первую очередь
[the 1–3 places a human should read with attention]

СТАТУС: ГОТОВО
```

**The last line is the status, and it is not optional.** Exactly one of three, on its
own line, as the final thing in the message:

- `СТАТУС: ГОТОВО` — the work is finished and nothing is waiting on a person.
- `СТАТУС: ЖДУ РЕШЕНИЯ — <what exactly>` — a stop rule fired, or intake is unanswered;
  what is written is committed and the report says what the decision is.
- `СТАТУС: БЛОКЕР — <what exactly>` — the run cannot continue for a reason no decision
  fixes: a stand that is down, access that does not exist, a dependency that will not
  build.

It exists because an unattended run is read by something before it is read by someone,
and prose cannot be told apart at a glance: a finished run, a run waiting on an answer
and a run that died all end in a wall of text. The same line form closes a
`project-healthcheck` report, so a watcher learns one convention rather than two.

The report language follows the developer's language. The status
line stays in this exact form in every language, because it is read by machines.

## Stop rules — the only mid-flow interruptions

A stop interrupts pushing forward, never preserving results: before any stop, commit
the work that is already written and verified as far as it could be (by Step 5's
convention), so a stopped run never strands green code in a dirty tree. Every stop
still ends with the handover report — the stop reason becomes its first section
(«Требует решения разработчика»), and the run continues through Steps 5–6 with what
it has.

Stop pushing forward and call the developer when:

1. A contradiction between the task statement and the reality of the code or the
   stand blocks the core of the task, or a fix would require changing the statement
   or its scope — that decision is the developer's, not yours. When the
   contradiction touches only part of the task, do not stop at all: implement
   everything that has a real code target and put the contradiction at the top of
   the handover.
2. Two full review cycles are done and findings remain — report them honestly,
   do not loop a third time.
3. `.claude/verify.md` contradicts reality (stand is down, test user is gone, the
   commands it names do not exist) — report exactly what each of its instructions
   returned, and do not improvise credentials or endpoints. Improvising means
   inventing addresses or credentials that exist nowhere in the repo; a run command
   the project's own README documents is a discovery, not an improvisation — offer
   it to the developer as a one-question choice (fix verify.md to match reality, or
   switch this run to tests-only), and never silently verify against a stand the
   config does not describe.
4. Tests keep failing after two focused fix attempts — hand over with the failing
   output. Never reclassify a failure as "tests not run".
