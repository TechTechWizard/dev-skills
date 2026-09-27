# API Check

## Input from config

Section `## API` of `<project>/.claude/healthcheck.md`: base URL per stand, how to
authenticate (or that a check runs unauthenticated), the list of key endpoints with the
response each is expected to give, and which stand the regular pass targets.

## Steps

1. **Liveness** — the health/status endpoint (or the cheapest unauthenticated GET the
   config names). Record HTTP status and latency. Three failures in a row with 5s
   pauses = the stand is down; stop the API section and mark it Critical.

2. **Key endpoints** — every endpoint the config lists, real requests via `curl -s -w`
   with status code and total time captured. Compare against the expected response the
   config states: status code always; body shape when the config spells it out.

3. **Auth boundary** — one deliberately unauthorized request to a protected endpoint.
   Expected: a clean 401/403 with the project's error shape, not a 500 and not a 200.

4. **Error shape** — one request that must fail validation (e.g. required field
   missing), only if the config marks such an endpoint as safe to call. Expected: 422
   (or the project's documented equivalent), not a 500.

## Rules

- **GET only, unless the config explicitly marks a mutating endpoint as safe** (e.g. a
  dedicated test-bundle flow). Default is: no POST/PUT/PATCH/DELETE against any stand.
- Latency is recorded for every request; thresholds come from the config, defaulting to
  OK < 500ms, Warning 500ms–2s, Critical > 2s per request.
- Save raw responses of anything that failed next to the report — a verdict without the
  response behind it cannot be argued with.
- An endpoint the config lists but you could not reach (auth missing, stand quirk) goes
  to «Не проверено и почему», never silently skipped.

## Output

| Endpoint | Expected | Actual | Latency | Status |
|----------|----------|--------|---------|--------|

plus one line per failed request pointing at its saved response file.
