# Frontend Check

## Input from config

Section `## Frontend` of `<project>/.claude/healthcheck.md`: stand URL, the critical
flow as a numbered list of steps (what to click, what must appear), test credentials if
the flow needs a login, and known cosmetic quirks that are not defects.

## Steps

1. **Load** — open the stand URL in a browser (chrome-devtools or playwright MCP).
   Record: page rendered (screenshot), time to load, HTTP status of the document.

2. **Console** — collect console messages. Errors = finding; warnings = observation.
   Filter out entries the config explicitly names as known noise.

3. **Network** — list failed requests (4xx/5xx) during load and flow. A 404 on a
   product asset (js/css/image/font) is a finding even when the page looks fine.

4. **Critical flow** — walk the config's steps exactly. After each step verify the
   config's stated expectation before moving on. Screenshot at every step whose number
   the config marks, and always at the final state.

## Rules

- Read-only stance: walking a flow may create ephemeral UI state, but must not submit
  anything that persists — unless the config marks the flow's data as test data with a
  documented cleanup.
- Screenshots are evidence, named `NN-what-is-on-it.png`, saved next to the report.
- A flow step that cannot be completed stops the flow: record the step number, the
  screenshot, console and network state at that moment — that triple is the bug report
  seed.
- Viewport: desktop by default; run mobile viewport too when the config asks for it.

## Output

| Step | Expected | Actual | Evidence | Status |
|------|----------|--------|----------|--------|

plus console/network summary: `console: N errors, M warnings (K known) | network: N failed`.
