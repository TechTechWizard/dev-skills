# Posting comments to a GitLab merge request

## The budget

Treat it as a limit, not a target.

- **One blocker:** the ask in a sentence, then three to five sentences — what breaks,
  when it breaks, and the suggested fix.
- **Non-blocking notes:** one or two sentences each, two or three notes in total.
- **Something done well:** one sentence, naming the decision rather than the person.
- Anything beyond that belongs in the report, not on the merge request.

**What to cut, in this order.** The walk-through of the mechanism — the author knows
their own codebase, so name the file, the line and the consequence, not the call
chain. Framework internals. Anything visible in their own diff. Checklist categories
with nothing to say. Restating the task back at them. And every recommendation with no
failure scenario behind it.

**What survives the cut:** `file:line`, what actually breaks, and the fix.

Two habits that keep it short. Group the non-blocking notes into one paragraph instead
of a bullet per finding. And when the same problem shows up across several merge
requests of one stack, say so once and propose a single fix for the whole feature
rather than repeating the explanation in each.

The reason this is a rule and not a preference: a wall of generated text costs the
author more time to read than the fix takes to make, and it buries the one thing that
actually blocks them.

## The shape of a comment

Tag the author first — their username comes from the merge request JSON
(`.author.username`). The tag is what notifies them: a comment without one waits in
the discussion until they happen to open the merge request. Lead with the ask, then
the detail:

```
@username, please resolve the conflicts in <file>.

Some details: <what breaks, when, and the suggested fix>
```

The tag is the default, not a fixture. When the developer said not to mention anyone
— a test merge request, an author who asked not to be pinged, a review of their own
branch — leave it out and open with the ask itself. The comment says the same thing;
it only stops knocking, and a notification, unlike the text, cannot be taken back.

In English, whatever language the review was discussed in.

## Anchoring a comment to a line

A comment on the line it is about is worth several paragraphs of explanation of where
to look. Use a general comment only when there is no line to attach to.

Inline comments need a **nested JSON `position` object**, sent with `--input`. The flat
form (`-f 'position[position_type]=text'`) is silently ignored by GitLab: the API
answers 201 and you get a general comment instead, which is how this goes wrong
without anyone noticing.

1. Get the diff refs:

   ```sh
   glab api projects/<url-encoded-path>/merge_requests/<iid>
   ```

   Take `.diff_refs` — `base_sha`, `head_sha`, `start_sha`.

2. Build the payload:

   ```json
   {
     "body": "<comment text>",
     "position": {
       "position_type": "text",
       "base_sha": "...",
       "head_sha": "...",
       "start_sha": "...",
       "new_path": "<file path>",
       "new_line": 42
     }
   }
   ```

   For a deleted line use `old_path` and `old_line` instead.

3. Post it, from a temporary file of its own, in two commands:

   ```sh
   payload=$(mktemp) && echo "$payload"
   # write the JSON above into that file
   ```

   ```sh
   glab api -X POST -H 'Content-Type: application/json' \
     projects/<url-encoded-path>/merge_requests/<iid>/discussions \
     --input "<payload path>"
   ```

   Write down the path the first command prints: a shell variable does not survive into
   the next command, and the file is needed again in step 4. For the same reason the
   post command ends with the post — no `; rm -f`, no `&& rm` after it. Either removes
   the file before anyone has read GitLab's answer, and the answer is what decides
   whether the file is still needed.

4. **Verify.** The note in the response must have `"type": "DiffNote"`. A general
   comment has `"type": null` — if that is what came back, delete it
   (`glab api -X DELETE .../notes/<note_id>`) and post again with a corrected
   position from the same file. Do not leave both. A comment deliberately posted as a
   general one, to `.../notes` because there is no line to attach it to, is verified by
   the response carrying a note `id`; `"type": null` is correct for it.

5. **Remove the file** once the note is verified, as a command of its own:
   `rm -f "<payload path>"`. Its body is a judgement on somebody's code, and a copy left
   in `/tmp` outlives the review; a fixed name such as `comment.json` also hands the
   next run a stale body to post by mistake, which is why the file gets a name from
   `mktemp` in the first place. When the post failed, or the verification failed and the
   repost did too, keep the file and tell the developer its path: the body is ready to
   post by hand, where rewriting it risks posting a different text.

The same file discipline holds for a general comment: write it to a `mktemp` file, post,
verify, and only then remove.

## Before posting anything

Show the developer what you are about to post and wait, unless they said to post
directly. A comment cannot be unsent from the author's notification, and a wrong one
costs more than the minute it takes to read it first.
