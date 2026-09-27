# .claude/verify.md — per-project stand verification config

This file lives in the **project repository**, not in the skill. The skill reads it at
Step 4 when the developer asked for live-stand verification. When the file is missing,
the intake message itself carries this template pre-filled with what you found in the
repo (the project's CLAUDE.md, CI config, .env.example) and the three options below —
the developer only picks an option and fills the blanks you could not.

## Template

```markdown
# Verification on the stand

## Stand

- URL: <https://dev.example.com or http://localhost:PORT>
- How to bring it up locally (if applicable): <docker compose up / sail up / ...>
- Last verified against: <URL actually used, date — updated by the skill after each
  live verification, so the file never silently drifts from reality>

## Access

- Test user: <login> / <where the password lives — env var, password manager entry;
  never the password itself in this file>
- API auth: <how to obtain a token — endpoint + test credentials reference>

## Data

- How to seed test data: <artisan command / seeder / fixture file / "already seeded">
- Data that must NOT be touched: <if the stand is shared — say what to leave alone>

## How to verify

- Backend: <base URL for direct API calls; example curl of a known-good request>
- UI (if applicable): <entry page for Playwright; a known-good click path>

## Known limitations

- <screens that do not exist yet, endpoints that are stubbed, flaky parts —
  so the skill does not report them as defects>
```

## Options to offer when proposing the file

Present these as choices inside the intake message:

1. **Local stand** — the skill brings the project up itself (docker/sail) and verifies
   against localhost. No shared-stand risk; needs the project to be runnable locally.
2. **Dev stand** — verification against the deployed dev environment with a test user.
   Real integrations, but shared data — the "must not touch" section becomes mandatory.
3. **Tests only for now** — no live verification this run; the file is created later.
   The handover report will state that live verification was skipped by choice.

For a pure library with no runnable stand (no web part, no docker config), options
1 and 2 collapse into "local runtime + tests" — say so in the intake instead of
offering empty stand fields.

After option 1 or 2 is chosen, the skill writes the file itself and asks only for
the blanks it can neither discover in the repo nor create on its own; Step 4 does
not start while those are missing. During verification the skill keeps the file
current — anything it creates (a test user, seeded data) or discovers (a working
URL, an auth recipe) goes into the file, and every such change is listed explicitly
in the handover report.
