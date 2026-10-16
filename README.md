# dev-skills

Six Agent Skills for ClickUp tasks, GitLab merge requests and code changes: small edits,
task implementation with self-review, commits, merge-request creation and review. The
skills use the [Agent Skills](https://agentskills.io) format, install with `npx skills`,
and work in Claude Code, Cursor and the other agents the installer supports.

## Install

```sh
npx skills add TechTechWizard/dev-skills -g -a claude-code -s '*'
```

`-g` installs for the user rather than for one project; `-a` names the agent (omit it to
be asked, `'*'` for every agent on the machine); `-s '*'` takes all six, or name the ones
you want.

Update later with `npx skills update`, remove with `npx skills remove`.

## Skills

| Skill | Example requests | What it does |
|---|---|---|
| `clickup` | a task id or link, "read the task", "create a task", "bug report" | Reads a task card, its comments and linked tasks and restates the task; or writes a task or bug report to the configured convention and reads it back to verify. Needs the `clickup` CLI, which the skill offers to install on first use. |
| `quick-edit` | "fix", "rename", "tweak" | Makes a small change while the developer watches, following the configured standards, and reports only what the diff does not show. |
| `implement-task` | "implement the task", "run this task" | Runs a prepared task on its own: standards, code, two rounds of self-review, verification, commits, handover report. |
| `commit` | "commit" | Makes one commit by the convention. With no details given, it proposes a message and waits. |
| `review-mr` | "review this MR", a merge-request link | Reads the task the merge request belongs to, reviews the change against that task and the checklist, and posts the findings as comments. Never edits the code. |
| `create-mr` | "create MR", "open a PR" | Pushes a committed branch and opens a merge request for it. |

`quick-edit` and `implement-task` cover different sizes of work. `quick-edit` is for a
change the developer is looking at right now. `implement-task` is for work that will go
to review: it adds an intake step, two review cycles and a report, so it is slower and is
not meant for small fixes.

The review skill is named `review-mr` rather than `code-review` because Claude Code has a
built-in skill named `code-review`, and a personal skill with the same name hides it.
Both `review-mr` and `implement-task` call the built-in skill to look for bugs.

## Standards

The skills do not include coding standards or task conventions. They read them from a
folder, and **the folder is a slot: whatever lies in it is the standard.** Nothing has to be
requested. Every run of `quick-edit`, `implement-task`, `commit` and `review-mr` lists the
slot on its own and opens the code standard for the stack it is about to touch; every run of
`clickup` opens the task and bug conventions the same way. A developer never mentions
standards in a prompt — asking a skill to "use the standards" changes nothing, and not asking
does not switch them off.

Two folders are looked at, in this order:

1. `<project>/.agents/standards/`, where `<project>` is the root of the repository the
   agent is working in. The folder is committed with the code, so everyone who works on
   that repository gets the same standards. For the subjects it covers it wins.
2. `~/.agents/standards/` — personal standards, answering every subject the project's
   folder says nothing about.

When neither folder has a matching standard, the skill says so in one line and falls back
to the general guidance it ships with. A missing standard never becomes a question to the
developer.

### How to see that the slot is wired

Each run names the documents it is about to read, in one line of ordinary text before the
first edit, and repeats the line in its answer or handover report:

```
Стандарт: ~/.agents/standards/laravel/code-style.md, ~/.agents/standards/general.md
```

That line is the check. Fill the slot, open a session in a project and ask for a small
change such as fixing a typo in a message. `quick-edit` should print a line like the one
above, naming files, not folders. A line saying the slot holds nothing for this stack means
the folder was not found or is empty: run `ls -L ~/.agents/standards` and compare with what
you expected to be there.

### Filling the slot

The folder can hold documents, symbolic links to documents, or symbolic links to whole
directories of documents. The skills do not expect particular file names: a session lists
the folder and opens the entries whose names match the current work. A new entry takes
effect on the next run, without changing or updating the skills.

```sh
mkdir -p ~/.agents/standards
ln -s ~/Work/<your-standards>/general.md       ~/.agents/standards/general.md
ln -s ~/Work/<your-standards>/code-review.md   ~/.agents/standards/code-review.md
ln -s ~/Work/<your-standards>/commit.md        ~/.agents/standards/commit.md
ln -s ~/Work/<your-frontend-docs>/docs         ~/.agents/standards/frontend
ln -s ~/Work/<your-docs>/task-convention.md    ~/.agents/standards/task.md
```

Name each entry after the stack or the activity it covers, because the session chooses
entries by name: `laravel`, `frontend`, `css`, `commit.md`, `task.md`. A team that
documents a new direction tomorrow drops one more entry in, and the skills start reading it
without learning its name first.

## Requirements

Only a supported agent is required. Some skills use additional tools:

- `clickup` needs the `clickup` CLI from
  [claude-work-tools](https://github.com/TechTechWizard/claude-work-tools) and a personal
  ClickUp API token. The skill offers to install the CLI; the token has to be created in
  ClickUp by the user.
- `create-mr` and `review-mr` need `glab`, authenticated against the GitLab instance.
- `create-mr` and `review-mr` read a ClickUp task through the same `clickup` CLI, and a
  GitLab issue through `glab`. Without the CLI or a token, the review still runs and its
  report says why the task was not checked.
- `implement-task` uses the built-in `code-review`, `security-review`, `simplify` and `run`
  skills when they are available, and states in the handover which reviewers ran.

### OpenCode

OpenCode reads `~/.agents/skills/`, where `npx skills` puts the canonical copies, so the
skills themselves need no setup. The standards folder does: OpenCode gates every read
outside the project directory behind `permission.external_directory`, whose default is
`ask`. The skill directories are allowed automatically, `~/.agents/standards/` is not. In
a headless run nobody can answer the prompt, so OpenCode rejects the read on its own
("permission requested: external_directory …; auto-rejecting") and the skill continues
without the standard. One entry in `~/.config/opencode/opencode.json` fixes it:

```json
{
  "permission": {
    "external_directory": {
      "~/.agents/standards/**": "allow",
      "/Users/<you>/.agents/standards/**": "allow",
      "~/Work/<your-docs>/**": "allow",
      "/Users/<you>/Work/<your-docs>/**": "allow"
    }
  }
}
```

The second pair of lines covers the directories the symbolic links in the standards folder
point to. Some models (gemini-3.1-pro) read the link's target path rather than the link,
and the target is outside the folder. Each path is written twice, with `~`
and absolute, because models spell it differently: gpt-5 requests the absolute
`/Users/<name>/.agents/standards/` rather than `~`. On an ordinary setup both lines match the
same directory; they differ when OpenCode runs with a `HOME` other than the account's (a
wrapper, a sandbox), and then the absolute line is the one that allows the read.

OpenCode's `glob` does not follow symbolic links and answers "No files found" for a full
standards folder. The skills therefore list the folder with `ls -L` or `find -L`, or open
it with the read tool, and never treat an empty glob as an empty folder.

OpenCode reads both `~/.claude/skills/` and `~/.agents/skills/`. When the same set is
installed in both, it writes a `duplicate skill name` warning per skill into its log
(visible with `--print-logs`), not into the session output, and keeps the copy it found
first, in `~/.claude/skills/`. The warning is harmless: `npx skills` makes each entry in
`~/.claude/skills/` a symbolic link to the copy in `~/.agents/skills/`, so both are the
same file.

## Repository layout

```
<name>/                 one directory per skill, flat at the root: SKILL.md, protocols/, references/
<name>/agents/          per-agent presentation metadata: openai.yaml names the skill in Codex
shared/                 the canonical copy of references several skills carry
scripts/sync-shared.sh  copies shared/ into every skill that carries the file; --check
evals/                  eval cases, run with `claude plugin eval .`
```

Each skill declares what it needs to run in its `compatibility:` field: the CLI it wraps,
the authentication it expects, and whether it relies on a built-in skill of the host.
Check it before installing a single skill rather than the whole set.

The Agent Skills format makes every skill self-contained — an installer copies the skill's
directory and nothing else — so four references (`standards.md`, `review-checklist.md`,
`commit-convention.md`, `verify-template.md`) exist once per skill that needs them. Edit
the copy in `shared/` and run `scripts/sync-shared.sh`. CI fails a push or pull request
where the copies differ, and `make check` runs the same check locally.

**Do not edit an installed skill in place.** `npx skills update` overwrites it without
asking. To change behaviour, create a separate skill under another name, or add a project
standard to the standards folder.

## Issues and contributions

Open an issue or send a pull request. The project has one maintainer and no guaranteed
response time.

## Licence

MIT. See [LICENSE](LICENSE).
