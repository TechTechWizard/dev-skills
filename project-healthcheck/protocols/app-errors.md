# App Errors & Queues

What the API/DB/frontend checks cannot see: exceptions users actually hit, and the
state of background work. Three sources, each optional per config — run the ones the
project's `## Errors` section describes.

## Sources

1. **Telescope** (when the project has laravel/telescope) — via the same connection
   recipe as the DB check, read-only:

   ```sql
   -- count over the window (default 7 days; config may override)
   SELECT count(*) FROM telescope_entries
   WHERE type='exception' AND created_at > now() - interval '7 days';

   -- latest details (content is text — cast to jsonb)
   SELECT created_at, (content::jsonb)->>'class' AS class,
          left((content::jsonb)->>'message', 120) AS message
   FROM telescope_entries WHERE type='exception'
   ORDER BY created_at DESC LIMIT 5;
   ```

   Mind Telescope's retention (pruning) — a zero can mean "no errors" or "entries
   pruned"; check the newest `created_at` of ANY telescope entry to tell which.

2. **Queues** — `failed_jobs` count (total and over the window) via the DB recipe.
   With Horizon (when the config says the project has it): `php artisan horizon:status`
   through the project's exec recipe, plus failed/pending from Horizon's own storage.
   Without Horizon: `jobs` table depth (stuck backlog) if the queue driver is database.

3. **Sentry** (when the config names a project/DSN and access is set up — Sentry MCP
   or API token): unresolved issues over the window, sorted by event count; new issues
   since the previous run. If access is not configured, the section goes to
   «Не проверено и почему» — never scrape the Sentry UI.

## Thresholds

| Metric | OK | Warning | Critical |
|--------|-----|---------|----------|
| Exceptions over window (Telescope/Sentry) | 0 | 1–10, no repeats | repeating class or > 10 |
| failed_jobs over window | 0 | 1–5 | > 5, or any failed job of a payment/notification kind |
| Queue backlog age (oldest pending) | < 5 min | 5–60 min | > 1 h |
| Horizon status | active | — | paused / not running |

## Rules

- Read-only everywhere: no pruning, no retrying failed jobs, no resolving Sentry issues.
- Every exception class reported gets its latest occurrence timestamp — «когда последний
  раз» matters more than the raw count.
- Known noise (config's known non-defects) is filtered but counted: "N entries, all
  known noise" — not silently dropped.

## Output

| Source | Window | Count | Latest | Status |
|--------|--------|-------|--------|--------|

plus per-exception lines (class, message, last seen) for anything non-zero.
