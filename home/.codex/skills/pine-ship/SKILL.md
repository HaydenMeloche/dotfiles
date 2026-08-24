---
name: pine-ship
description: Ship a Pine pull request: review and commit the current branch, push it to GitHub, and open a Pine PR. Use when the user says "pine ship", "ship this Pine PR", or asks to commit, push, and create a Pine PR.
---

# Pine Ship: Commit, Push, And Create A Pine PR

Use this skill when the user asks to ship work in a Pine repository: commit local work, push the branch, and create a GitHub pull request.

## Gather Context

Run these in parallel where possible:

- `git status`
- `git diff HEAD`
- `git log --oneline -10`
- `git branch --show-current`

Inspect the diff before staging. If unrelated user changes are present, do not revert them. Stage only the files that belong in the requested PR.

## Commit

- Stage specific changed files instead of using `git add -A`.
- Write a concise, meaningful commit message following the repository's recent style.
- Pass the message non-interactively.
- If a pre-commit hook fails, fix the issue and create a new commit. Do not amend unless the user explicitly asks.

## Push

Push the branch to origin with tracking:

```bash
git push -u origin <branch-name>
```

Never push directly to `main` or `master`. If currently on one of those branches, warn the user and stop before pushing.

## Create PR

Fetch the PR template:

```bash
curl -s https://raw.githubusercontent.com/pinecorpca/.github/refs/heads/master/PULL_REQUEST_TEMPLATE.md
```

Fill in the template based on the changes. Determine the appropriate risk level:

- `Risk: None`: minor changes, docs, or well-tested features.
- `Risk: Minimal`: feature additions, refactoring, moderate impact.
- `Risk: Moderate`: significant or breaking changes, complex features.
- `Risk: High`: major system changes, security updates, core functionality.

Check the matching risk checkbox in the template body and add the corresponding label to the PR.

Create the PR with `gh pr create`, passing the matching `--label` flag. Keep the title under 70 characters.

## Notes

- Never use `--no-verify` or force-push unless explicitly asked.
- Return the PR URL when done.
