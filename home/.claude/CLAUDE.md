# Rex

When a startup message says I'm running in a Rex terminal:

- `REX_SESSION`/`REX_BLOCK` are often empty in the Bash tool's shell. Use the IDs
  from the startup message and verify them with `rex ls --json`. If they're
  stale, ask which session I'm in rather than guessing.
- One Claude per session, and never two Claudes in the same checkout. Use a
  worktree per session.
- Open a pane only when the user needs to see or type something, or the
  project says to use one. Run tests, builds and log tails through the Bash tool
  (`run_in_background` for slow ones).
- Commands the user needs to run, like `sudo`, go in a split beside my pane with
  focus. The `!` prefix has no terminal to read a password from. Ask the user to
  say when they're done, check the result, then close the split.
- Tab names: **Server** for dev servers and workers (one pane per service,
  `--focus=false --keep-open`), **Review** for diffs, `gr`, `lazygit`, and
  **Shell** for the user's terminal.
- Never type into my own pane or the Shell tab, and read Shell only when asked.
  Don't move the user's focus unless they should look now.
- Close panes I opened once their step is done. At the end of a task, list what
  I left running and ask before closing anything I didn't open.

# Working style

- Do implementation work myself. Subagents are for broad read-only searches,
  parallel research, or an independent review, and should be rare. Review any
  diff before committing, whoever wrote it.
- Before coding, state assumptions that change the result. If a simpler
  approach exists, say so and push back.

## Code changes
- Do the smallest change that solves the problem. Don't add behaviour the old
  code didn't have (e.g. new suffixes, formats, fields) without asking.
- Prefer simple code over clever code. If a fix grows complicated, stop and say so.
- Touch only what the task needs: don't reformat, rename, or refactor adjacent
  code, and match the existing style. Mention unrelated dead code rather than
  deleting it, but remove anything my own change left unused.
- Default to no code comments.
- Tests must exercise the real code, not a copy or stub of it.
- Reproduce or prove a bug before proposing a fix PR.
- For perf or infra changes, measure before and after locally and put the
  numbers in the commit body.

## Git and PRs
- Branch new work off a freshly fetched `origin/master`, never a stale local one.
- One commit per logical change. Don't bundle unrelated fixes.
- After pushing to a PR: update the PR description to match, then check CI and
  review comments (including Codex) and report them without being asked.
- Once a PR I opened from a worktree I created is merged (check with
  `gh pr view`), remove the worktree, the local branch, the remote branch if
  GitHub didn't, and any Rex tabs I opened for it. Never delete a worktree or
  branch I didn't create, or one with uncommitted or unpushed work; ask instead.

## Verifying
- Check things myself with the CLIs the user has (aws, gh, sentry, psql) before
  asking or guessing.

## Handing things to the user
- Answer in chat by default. Only make an artifact when asked.
- Text to paste somewhere (Slack, SQL, commands): show it in chat and `pbcopy` it.
- Files to review go on ~/Desktop. Images, GIFs and HTML: `open` them.
- If the user offers to run something, give the raw command or SQL, not a script.
- Number options so the user can reply "do 1 and 3".

## Writing for the user
- Plain, casual, direct. No corporate tone or marketing.
- No "we", no third person about the product. Don't write in the user's voice
  unless asked.
- Use colons rather than one-word fragments ending in periods.
- Slack summaries: two lines max.
