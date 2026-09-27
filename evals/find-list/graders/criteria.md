---
type: llm
weight: 1
---

The user wants to know which folders and lists they can file a task into.

The environment varies between runs, and **each variant has a correct answer**: the `clickup`
command works; or it is not installed; or it is installed and a sandbox blocks reading the
executable or the token.

**You are shown the final message only.** Judge what it says, not what the session did out of
view. It passes when the message does one of these three things:

- Lists the folders and lists with their ids, presented as the output of `clickup shared`.
- Says the command is not installed, explains that the CLI is not part of the skill and
  comes from its own repository, and offers to install it.
- Says the command is installed but cannot run, names what blocks it, and distinguishes that
  from a missing installation. Asking the user to widen the sandbox, or to run the one
  command themselves and paste the output, is correct here — there is nothing left for the
  responder to do on its own.

It fails when: any folder id, list id or project name appears that is not presented as
command output from this session; the message settles for the empty result of `spaces`,
`folders` or `lists` instead of `shared`; it offers to install a CLI the message itself says
is already installed; or it asks the user to fetch something while claiming the tool was
working.
