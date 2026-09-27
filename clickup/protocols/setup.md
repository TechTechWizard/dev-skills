# Setup

## When to apply

The first time in a session that `clickup` is needed and the shell answers
`command not found: clickup`, or when a call fails because there is no token. Do not run
this protocol speculatively — a working installation must cost the user nothing, and
checking is one failed command, not a survey.

Also run it when the user asks to install or set up ClickUp access, in any wording.

## What this protocol is for

A skill is text; it cannot carry the executable — `npx skills` installs Markdown and
scripts, not a binary with a token. So the CLI lives in its own repository and has to
arrive separately. That is the whole reason this protocol exists, and it is why the missing tool
is an expected state on a first run rather than a broken installation.

## Steps

1. **Say what is missing and what you propose to do, in one message, then wait.** Never
   install without a yes. The message names the repository, the directory the checkout
   will land in, and the fact that `install.sh` creates symbolic links in `~/.local/bin`
   and changes nothing else:

   > The `clickup` command is not installed. It lives in `claude-work-tools`. With your
   > permission I will clone it into `<dir>` and run its installer, which links the tools
   > into `~/.local/bin`. You will then need a personal ClickUp API token, which only you
   > can create.

   Default directory: `~/.local/share/claude-work-tools`. Offer it; let the user name
   another.

2. **Clone and install.**

   ```sh
   git clone https://github.com/TechTechWizard/claude-work-tools.git <dir>
   cd <dir> && ./install.sh
   ```

   The installer prints which prerequisites are present and which are not. Relay that list
   as it is — it is written for a human.

   **If the clone fails**, the repository is public and needs no credential, so the
   cause is the network or a missing `git`, not access. Report the error as it came back
   rather than guessing, and do not try other URLs or protocols.

3. **Check the PATH.** If the installer reports that `~/.local/bin` is not on `PATH`, give
   the one line to add to their shell profile and say which file (`~/.zshrc` for zsh,
   `~/.bashrc` for bash), then have them open a new shell. Do not edit their profile
   yourself without asking — it is their environment, and a bad line there breaks every
   future shell.

4. **The token is the user's job.** You cannot create it: it comes from the ClickUp web
   interface, under Settings → Apps → API Token. Give that path, and the command to store
   it:

   ```sh
   mkdir -p ~/.config/clickup
   echo 'pk_...' > ~/.config/clickup/token
   ```

   Say what the token is: personal, and everything the CLI does is done as them. Nothing
   else needs configuring — the workspace and their user id are discovered from the API on
   first use.

5. **Verify before declaring success.** Run `clickup my-tasks`. Tasks listed means the
   whole chain works: command found, token valid, workspace resolved. Then run
   `clickup shared` once and show the result — it is the map of folders and lists this
   person can reach, and the ids in it are what every other command takes.

6. **Return to what the user actually asked for.** Setup is an interruption, not the
   errand. Once `my-tasks` works, go back to the original request without making them
   repeat it.

## Result

A working `clickup`, a stored token, and the user's own folder map printed once. Report in
two or three sentences what was installed and where, so they can find or remove it later.

## Rules

- **One consent, at the start.** Ask before the clone, then carry the whole sequence
  through. Asking again before the installer, again before the token, turns five minutes
  into a conversation.
- **Never invent a token, a workspace id or a user id.** All three come from the user or
  the API. A placeholder written into the config file produces failures that look like
  network errors.
- **Do not install anything that was not asked for.** Not a terminal multiplexer, not glab, not a shell
  framework. The installer names them as optional; that is all they are here.
