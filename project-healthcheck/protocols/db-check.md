# DB Check

Common to Laravel projects on Kubernetes: the SQL battery and the thresholds are the
same from project to project, and only the recipe for reaching the database differs.

## Input from config

Section `## Database` of `<project>/.claude/healthcheck.md`: the exact connection
recipe. Two known shapes, copy whichever the project uses:

- **Exec into a pod and query through the application**, for a database that is not
  reachable from outside the cluster: kubectl context, namespace, pod selector, and
  the application's own console — for Laravel, `php artisan tinker --execute="<PHP>"`.
- **Port-forward and connect with a client**, where the database accepts a direct
  connection: kubectl context, service, the secret holding the password,
  `PGPASSWORD=... psql -h 127.0.0.1 -p <port> ...`, and the cleanup that tears the
  forward down (`pkill -f "port-forward.*<port>"`) — cleanup runs even when the query
  failed.

## The battery (PostgreSQL)

Run all independent checks in parallel where the recipe allows. Every check read-only.

1. **Connection & basics** — server version, database name, connection alive.
2. **Size & connections** — `pg_database_size`; active/idle/total from
   `pg_stat_activity`; `SHOW max_connections`.
3. **Top tables by size** — top 10–15 from `pg_stat_user_tables` /`pg_tables` with
   total/table/index size (`pg_size_pretty`) and `n_live_tup`.
4. **Bloat & vacuum** — dead tuples (`n_dead_tup > 1000`), dead %, `last_autovacuum`,
   `last_autoanalyze`.
5. **Cache hit ratio** — `pg_statio_user_tables`:
   `sum(heap_blks_hit) / nullif(sum(heap_blks_hit)+sum(heap_blks_read),0)`.
6. **Long-running queries** — `pg_stat_activity`, state != idle, `> 5s`, query text
   truncated to 100 chars.
7. **Blocked locks** — `pg_locks WHERE NOT granted`.
8. **Index usage** — tables with `seq_scan + idx_scan > 100`: seq scans, idx usage %.
9. **Unused indexes** — `idx_scan = 0`, size > 1 MB, non-unique.
10. **XID wraparound** — transaction ID age vs `autovacuum_freeze_max_age`.

The exact SQL for 1–9 belongs to the project, not to this skill: a project that runs
these checks keeps them in its own `.claude/protocols/db-healthcheck.md`, in whichever
form its access allows — raw `psql` where the database is reachable directly, a Tinker
wrapper where it is only reachable through the application. Read that file and use its
queries verbatim rather than retyping them from memory; when the project has none, say
so in the report's gap list instead of inventing queries against an unfamiliar schema.

## Thresholds

| Metric | OK | Warning | Critical |
|--------|-----|---------|----------|
| Cache hit ratio | > 99% | 95–99% | < 95% |
| Connections usage (of max) | < 50% | 50–80% | > 80% |
| XID wraparound | < 25% | 25–50% | > 50% |
| Dead tuples % | < 10% | 10–20% | > 20% |
| Waiting locks | 0 | 1–5 | > 5 |
| Long queries (> 5s) | 0 | 1–3 | > 3 |
| Index usage | > 80% | 50–80% | < 50% |

## Rules

- Read-only diagnostics; never VACUUM, never kill queries, never touch data — a finding
  produces a recommendation, not an action.
- Tables under ~1000 rows: low index usage is acceptable (lookup tables) — do not flag.
- Telescope/log/audit tables that dominate DB size are flagged as their own line, not
  mixed into the general size verdict.
- Always show absolute values alongside percentages.

## Output

Summary table (metric, value, status) + top-tables table + problems with
recommendations, per the report shape in SKILL.md.
