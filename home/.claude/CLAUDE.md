# Rex

When `REX_SESSION` is set, I'm running in a Rex pane. Use the `rex` skill for
the CLI guide.

- One Claude per session, and never two Claudes in the same checkout. Use a
  worktree per session.
- Open a pane only when the user needs to see or type something, or the
  project says to use one. Run tests, builds and log tails through the Bash tool
  (`run_in_background` for slow ones).
- Commands the user needs to run, like `sudo` or `aws login`, go in a split
  beside my pane with focus. The `!` prefix has no terminal to read a password
  from. Ask the user to say when they're done, check the result, then close the
  split.
- Tab names: **Server** for dev servers and workers (one pane per service,
  `--focus=false --keep-open`), **Review** for diffs, `gr`, `lazygit`, and
  **Shell** for the user's terminal.
- Never type into my own pane or the Shell tab, and read Shell only when asked.
  Don't move the user's focus unless they should look now.
- Close panes I opened once their step is done. At the end of a task, list what
  I left running and ask before closing anything I didn't open.

## Session names

Name the session once the first request makes the work clear:
`rex session rename "$REX_SESSION" '<label>'`.

- Format: `<Project> - <task>`, e.g. `Dotfiles - Claude config sync`.
- Project is the repo or the area of it the work is in, Title Case. Task is a
  few words in sentence case.
- Keep a leading number (`3 Dotfiles - ...`); it's the session's Alt-number.
- Keep the label if it already describes the same work. Don't rename again
  for small detours.

# Working style

- Do implementation work myself. Subagents are for broad read-only searches,
  parallel research, or an independent review, and should be rare. Review any
  diff before committing, whoever wrote it.
- Before coding, state assumptions that change the result. If a simpler
  approach exists, say so and push back.
- When asked how something would work or to explain an approach, answer and
  stop. Don't start the work until asked.

## Code changes
- Do the smallest change that solves the problem. Don't add behaviour the old
  code didn't have (e.g. new suffixes, formats, fields) without asking.
- Prefer simple code over clever code. If a fix grows complicated, stop and say so.
- Touch only what the task needs: don't reformat, rename, or refactor adjacent
  code, and match the existing style. Mention unrelated dead code rather than
  deleting it, but remove anything my own change left unused.
- Default to no code comments.
- Don't add tests for small fixes unless asked.
- Tests must exercise the real code, not a copy or stub of it.
- Reproduce or prove a bug before proposing a fix PR.
- For perf or infra changes, measure before and after locally and put the
  numbers in the commit body.
- To check a user-supplied redirect URL stays in the app, don't match
  prefixes (`startsWith('/') && !startsWith('//')`). Browsers strip tab/CR/LF
  and read `\` as `/`, so `/%09/evil.com` and `/\evil.com` still go off-site.
  Require a leading `/`, then keep the value only if resolving it against two
  different placeholder hosts keeps each one's host:
  `['http://a.invalid', 'http://b.invalid'].every((b) => new URL(url, b).host === new URL(b).host)`,
  in a try/catch.

## Git and PRs
- Don't commit or push unless asked. Leave changes uncommitted so the user can
  look at them first.
- Branch new work off a freshly fetched `origin/master`, never a stale local one.
- One commit per logical change. Don't bundle unrelated fixes.
- After pushing to a PR: update the PR description to match, then check CI and
  review comments (including Codex) and report them without being asked.
- Codex and Cursor Bugbot review again on every push and when a draft is marked
  ready. Wait for both. When Codex finds nothing it posts no review: read the
  `codex-review-state` blob in its summary comment (`status`, `has_any_findings`,
  `commit_sha` matching head). Bugbot is the "Cursor Bugbot" check: neutral
  means it left inline comments. Reply to each bot comment with the fixing commit.
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
- Clear and concise over polished. Lead with the fact; cut setup, narration
  and meta-framing ("this page explains…", "at the start of the week…",
  "this week…").
- Don't write like an AI copywriter: no slogans, taglines, punchy contrasts
  ("One way in. No way in.") or dramatic rhythm. Headings name the thing
  plainly ("Network changes, Nov 17–21").
