# Review checklist

The fallback checklist, used when the lookup in `standards.md` finds nothing
closer. This is the review criteria for
every path in Step 3: the filter applied to the built-in `code-review` skill's and
`ocr`'s findings, and the checklist for your own review pass when neither tool is
available. Review the diff, not the surrounding code.

## 1. Implementation

- The code does what the task statement asks — compare against the goals, not the
  diff's own intent.
- Can the solution be simplified? Is the abstraction at the level the codebase
  already uses?
- No unnecessary dependencies; an existing solution in the codebase is reused when
  one fits.
- SOLID and YAGNI hold.

## 2. Logic

- Are there inputs, use cases, or external circumstances where the code behaves
  differently from the intent? Edge cases, empty/extreme values, concurrency.

## 3. Error handling and logging

- Errors are handled, and handled correctly; messages are clear to their audience.
- Enough information to debug a failure; no noisy or secret-leaking logs.

## 4. Dependencies and impact

- Updates outside the code (docs, config, README) done where needed.
- The change does not silently break other parts of the system or backward
  compatibility.

## 5. Security and data privacy

- Authorization and authentication are handled correctly.
- Incoming data is validated; data from external APIs and libraries is checked.
- Sensitive data is stored and processed safely; no keys, passwords, or usernames
  exposed.

## 6. Performance

- No degradation introduced; obvious cheap improvements taken.

## 7. API usability

- The API is documented well enough and reflects what it is for.

## 8. Testing

- The code is testable and covered: enough unit/integration tests, edge cases
  included, in the project's existing test style.

## 9. Readability

- Easy to understand; naming helps; files and folders follow the project layout.
- Comments explain "why", not "what"; no commented-out code; no comments that
  restate the obvious.

## Quality standards (unfinished functionality)

- Unfinished screens have stubs; unimplemented buttons show an informational
  alert/toast.
- Stubs are reusable components; unfinished code carries a clear `TODO:`.
- On production products, new functionality is behind feature flags.
