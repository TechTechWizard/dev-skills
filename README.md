# skills

Agent Skills for working the way we actually work: tasks in ClickUp, merge requests in
GitLab, and a development step that ends at something you can look at. Six skills in the
[Agent Skills](https://agentskills.io) format, installed with `npx skills`, usable from
Claude Code, Cursor and every other agent the installer supports.

## Install

```sh
npx skills add TechTechWizard/skills -g -a claude-code -s '*'
```

`-g` installs for the user rather than for one project; `-a` names the agent (omit it to
be asked, `'*'` for every agent on the machine); `-s '*'` takes all six, or name the ones
you want. Nothing else is needed: the repository is public, so the clone goes over HTTPS
and asks for no credential and no access.

Update later with `npx skills update`, remove with `npx skills remove`.

## What is here

| Skill | You say | What happens |
|---|---|---|
| `clickup` | «прочитай задачу», a task id or link, «заведи таску», «багрепорт» | The card, comments and linked tasks read into a statement in your own words; or a task or bug report written to your team's convention and read back to verify. Needs the `clickup` CLI, which the skill offers to install on first use. |
| `quick-edit` | «поправь», «почини», «переименуй» | A small change you are watching, to the team's conventions, and back only what the diff does not say. |
| `implement-task` | «реализуй задачу», «запускай в работу» | A prepared task run on its own: standards, code, two rounds of self-review, verification, commits, handover report. |
| `commit` | «закоммить» | One commit by the convention. With no details given, it proposes a message and waits. |
| `review-mr` | «сделай ревью», a merge-request link | Somebody else's merge request read against the checklist, with the findings posted as comments. Never edits the code. |
| `create-mr` | «создай MR», «на ревью» | A committed branch pushed and turned into a merge request. |

The line that matters is between `quick-edit` and `implement-task`. The first is for a
change you are looking at right now; the second is for work someone else will review, and
it costs accordingly — an intake, two review cycles, a report. Asking the heavy one for a
typo is how people conclude that skills are in the way.

`review-mr` is called that, and not `code-review`, because Claude Code ships a built-in
skill named `code-review` and a personal skill with the same name hides it from the list —
and both `review-mr` and `implement-task` call the built-in one to hunt bugs.

## Your team's rules do not travel in here

None of these skills ships anybody's standards. `quick-edit`, `implement-task`, `commit`
and `review-mr` look the team's code standards up; `clickup` looks the task and bug
conventions up. Both look in the same place, and that place is a folder:

1. `<project>/.claude/standards/` — committed into the project, so everyone working on it
   gets the same answer, including someone with nothing set up.
2. `~/.claude/standards/` — yours.

Then a company knowledge base over MCP if one is configured, then a thin
general-practice fallback that ships with the skill.

**Put in the folder whatever you want the skills to read.** The documents themselves,
symbolic links to documents, or symbolic links to whole directories of documents in a
checkout you already have — all three work, and nothing inside these skills declares what
ought to be there. A session lists the folder and opens what matches the work in front of
it, so a direction your company documented yesterday starts answering the moment somebody
drops a link in, with no change to any skill and no update to install.

```sh
mkdir -p ~/.claude/standards
ln -s ~/Work/<your-standards>/general.md       ~/.claude/standards/general.md
ln -s ~/Work/<your-standards>/code-review.md   ~/.claude/standards/code-review.md
ln -s ~/Work/<your-standards>/commit.md        ~/.claude/standards/commit.md
ln -s ~/Work/<your-frontend-docs>/docs         ~/.claude/standards/frontend
ln -s ~/Work/<your-docs>/task-convention.md    ~/.claude/standards/task.md
```

Name each entry after the stack or the activity it covers, because that name is all a
session has to go on when it decides what this change needs. Beyond that there is no
convention to learn.

A missing standard never stops the work: the skill says which file answered, once, and
carries on.

## What the skills expect

Claude Code or another supported agent, and nothing else mandatory. Each skill degrades
rather than refuses:

- `clickup` needs the `clickup` CLI from
  [claude-work-tools](https://github.com/TechTechWizard/claude-work-tools) and a personal
  ClickUp API token; the skill explains and installs the CLI once you agree, the token only
  you can create.
- `create-mr` and `review-mr` need `glab`, authenticated against your GitLab.
- `implement-task` uses the built-in `code-review`, `security-review`, `simplify` and `run`
  skills when they are there, and says in the handover which reviewers actually ran.

### On OpenCode

OpenCode reads `~/.agents/skills/`, where `npx skills` puts the canonical copies, so the
skills themselves need no setup. The standards slot does: OpenCode gates every read
outside the project directory behind `permission.external_directory`, whose default is
`ask`. The skill directories are allowed automatically, `~/.claude/standards/` is not, and
in a headless run there is nobody to answer — the host replies "The user rejected
permission", and the session ends with exit code 0 and no final text, which looks like a
run that simply said nothing. One entry in `~/.config/opencode/opencode.json` fixes it:

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

The second line stands for the directories your slot links point at. It is needed because
some models (gemini-3.1-pro in some runs) read the link's target path rather than the link,
and the target is outside the slot. Each path is written twice, with `~` and absolute,
because the models do not spell it the same way: gpt-5 in some runs asked for
`/Users/<name>/.claude/standards/` literally rather than through `~`. On an ordinary setup
the two lines match the same directory; they part when OpenCode runs with a `HOME` other
than your account's (a wrapper, a sandbox), and then the absolute line is the one that lets
the read through. With these allowed, the skills behave in OpenCode as they do in Claude
Code.

The slot entries are symbolic links, and OpenCode's `glob` does not follow them: it answers
"No files found" for a full slot. The skills therefore list the slot with `ls -L` or
`find -L`, or open the folder with the read tool, and never take an empty glob as an empty
slot.

One more thing, which you will only see in the log: OpenCode reads both
`~/.claude/skills/` and `~/.agents/skills/`, so when the same set is installed in both it
writes a `duplicate skill name` warning per skill into its log (visible with
`--print-logs`), not into the session's output. That is expected and harmless; the model
takes the copy from `~/.agents/skills/`.

## How this repository is laid out

```
<name>/                 one directory per skill, flat at the root: SKILL.md, protocols/, references/
<name>/agents/          per-agent presentation metadata: openai.yaml names the skill in Codex
shared/                 the canonical copy of references several skills carry
scripts/sync-shared.sh  copies shared/ into every skill that carries the file; --check
evals/                  eval cases, run with `claude plugin eval .`
```

Each skill declares what it needs to run in its `compatibility:` field — the CLI it wraps,
the authentication it expects, whether it leans on a built-in skill of the host. Read it
before installing one skill rather than the set.

Skills sit flat at the root, the layout most Agent Skills repositories use, so this set
installs with the same command as the others and looks the same to whoever opens it.

The Agent Skills format makes every skill self-contained — an installer copies the skill's
directory and nothing else — so four references (`standards.md`, `review-checklist.md`,
`commit-convention.md`, `verify-template.md`) exist once per skill that needs them. Edit
the copy in `shared/`, run `scripts/sync-shared.sh`, and the check refuses a commit where
the copies have drifted.

**Do not edit an installed skill in place.** `npx skills update` overwrites it without
asking. Disagree by writing your own skill under another name, or by putting a project
standard into the slot above.

## Reporting something

Open an issue, or send a pull request. There is one maintainer and no promise about how
fast a change lands, which is worth knowing before you wait on one.

## Licence

MIT. See [LICENSE](LICENSE).
