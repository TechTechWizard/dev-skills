# Usage Report

Product usage statistics — reporting on top of the same access the DB check uses.
When the project has an analytics skill of its own, run that one and stop: it knows
the product's metrics and this protocol does not. What follows is for a project that
has none.

## Input from config

Section `## Usage` of `<project>/.claude/healthcheck.md`: the metric list — each metric
is a name plus the query (or tinker expression) that computes it, and, where trends
matter, the grouping period (daily/weekly/monthly). Plus the output format the project
wants: markdown section in the healthcheck report (default) or a standalone HTML file.

## Steps

1. Reuse the connection recipe from `## Database` — same rules, read-only.
2. Compute every configured metric. For trend metrics, compute the current period and
   at least two previous ones — a number without its trend reads as noise.
3. Compare against the previous report in the project's reports directory (see the
   skill's Report section) when one exists — call out metrics that moved more than the
   config's attention threshold (default ±20% period-over-period).

## Rules

- Metrics come from the config, not from your ideas of what is interesting — propose
  new ones in the report's observations, and add them only when asked to.
- Absolute numbers next to every percentage.
- No user-level data in the report: aggregates only, unless the config explicitly
  scopes a metric to an entity list.

## Output

Per metric: current value, previous periods, trend arrow, one-line reading of what it
means. Standalone HTML, when the configuration asks for it, follows the same order.
