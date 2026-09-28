# skills

Six Agent Skills for ClickUp tasks, GitLab merge requests and code changes: small edits,
task implementation with self-review, commits, merge-request creation and review. The
skills use the [Agent Skills](https://agentskills.io) format, install with `npx skills`,
and work in Claude Code, Cursor and the other agents the installer supports.

## Install

```sh
npx skills add TechTechWizard/skills -g -a claude-code -s '*'
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
| `review-mr` | "review this MR", a merge-request link | Reviews a merge request against the checklist and posts the findings as comments. Never edits the code. |
| `create-mr` | "create MR", "open a PR" | Pushes a committed branch and opens a merge request for it. |

`quick-edit` and `implement-task` cover different sizes of work. `quick-edit` is for a
change the developer is looking at right now. `implement-task` is for work that will go
to review: it adds an intake step, two review cycles and a report, so it is slower and is
not meant for small fixes.

The review skill is named `review-mr` rather than `code-review` because Claude Code has a
built-in skill named `code-review`, and a personal skill with the same name hides it.
Both `review-mr` and `implement-task` call the built-in skill to look for bugs.

## Standards

The skills do not include coding standards or task conventions. `quick-edit`,
`implement-task`, `commit` and `review-mr` read code standards, and `clickup` reads task
and bug conventions, from the same folder, in this order:

1. `<project>/.claude/standards/` — committed to the project and shared by everyone who
   works on it.
2. `~/.claude/standards/` — personal standards.

After that comes a knowledge base over MCP, if one is configured, and then the general
guidance each skill ships with.

The folder can hold documents, symbolic links to documents, or symbolic links to whole
directories of documents. The skills do not expect particular file names: a session lists
the folder and opens the entries that match the current work. A new entry takes effect
immediately, without changing or updating the skills.

```sh
mkdir -p ~/.claude/standards
ln -s ~/Work/<your-standards>/general.md       ~/.claude/standards/general.md
ln -s ~/Work/<your-standards>/code-review.md   ~/.claude/standards/code-review.md
ln -s ~/Work/<your-standards>/commit.md        ~/.claude/standards/commit.md
ln -s ~/Work/<your-frontend-docs>/docs         ~/.claude/standards/frontend
ln -s ~/Work/<your-docs>/task-convention.md    ~/.claude/standards/task.md
```

Name each entry after the stack or the activity it covers, because the session chooses
entries by name.

When no standard is found, the skill uses its built-in guidance, says which source it
used, and continues.

## Requirements

Only a supported agent is required. Some skills use additional tools:

- `clickup` needs the `clickup` CLI from
  [claude-work-tools](https://github.com/TechTechWizard/claude-work-tools) and a personal
  ClickUp API token. The skill offers to install the CLI; the token has to be created in
  ClickUp by the user.
- `create-mr` and `review-mr` need `glab`, authenticated against the GitLab instance.
- `implement-task` uses the built-in `code-review`, `security-review`, `simplify` and `run`
  skills when they are available, and states in the handover which reviewers ran.

### OpenCode

OpenCode reads `~/.agents/skills/`, where `npx skills` puts the canonical copies, so the
skills themselves need no setup. The standards folder does: OpenCode gates every read
outside the project directory behind `permission.external_directory`, whose default is
`ask`. The skill directories are allowed automatically, `~/.claude/standards/` is not. In
a headless run nobody can answer the prompt, so the host replies "The user rejected
permission" and the session ends with exit code 0 and no final text. One entry in
`~/.config/opencode/opencode.json` fixes it:

```json
{
  "permission": {
    "external_directory": {
      "~/.claude/standards/**": "allow",
      "/Users/<you>/.claude/standards/**": "allow",
      "~/Work/<your-docs>/**": "allow",
      "/Users/<you>/Work/<your-docs>/**": "allow"
    }
  }
}
```

The second pair of lines covers the directories the symbolic links in the standards folder
point to. Some models (gemini-3.1-pro in some runs) read the link's target path rather
than the link, and the target is outside the folder. Each path is written twice, with `~`
and absolute, because models spell it differently: gpt-5 in some runs requested
`/Users/<name>/.claude/standards/` literally. On an ordinary setup both lines match the
same directory; they differ when OpenCode runs with a `HOME` other than the account's (a
wrapper, a sandbox), and then the absolute line is the one that allows the read.

OpenCode's `glob` does not follow symbolic links and answers "No files found" for a full
standards folder. The skills therefore list the folder with `ls -L` or `find -L`, or open
it with the read tool, and never treat an empty glob as an empty folder.

OpenCode reads both `~/.claude/skills/` and `~/.agents/skills/`. When the same set is
installed in both, it writes a `duplicate skill name` warning per skill into its log
(visible with `--print-logs`), not into the session output. The warning is harmless; the
model uses the copy from `~/.agents/skills/`.

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

Skills sit flat at the root, which is the common layout for Agent Skills repositories.

The Agent Skills format makes every skill self-contained — an installer copies the skill's
directory and nothing else — so four references (`standards.md`, `review-checklist.md`,
`commit-convention.md`, `verify-template.md`) exist once per skill that needs them. Edit
the copy in `shared/` and run `scripts/sync-shared.sh`; the check rejects a commit where
the copies differ.

**Do not edit an installed skill in place.** `npx skills update` overwrites it without
asking. To change behaviour, create a separate skill under another name, or add a project
standard to the standards folder.

## Issues and contributions

Open an issue or send a pull request. The project has one maintainer and no guaranteed
response time.

## Licence

MIT. See [LICENSE](LICENSE).
