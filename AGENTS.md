# Agent notes

Personal macOS dotfiles. `bootstrap` installs everything; `README.md` lists what each file does.

## This repo is public

- Never commit work repo or org names, client or partner URLs, trusted project paths, hostnames, tokens or keys.
- Private values live outside the repo: `~/.zshlocal` (shell), `~/.gitconfig.local` (Git identity), `~/.repos.tsv` (repos to clone), `~/.codex/skills` (work skills).
- Read the full diff for these before every commit.

## How files are installed

- Most files under `home/` are symlinked into `~`, so editing `~/.zshrc` edits this repo.
- Files that apps write machine state into are copied once instead of linked: `~/.codex/config.toml`, `~/.gitconfig.local`, `~/.ssh/config`. Don't symlink a file an app rewrites.
- A new config file needs a line in `bootstrap` and in the README's "What is configured" list.

## Lines apps add on their own

Codex, Claude Code and Docker Desktop append to config files (project trust entries, hook hashes, a Docker `compinit` block). Don't commit those; move anything worth keeping into the right place by hand.

## Shell load order

- `.zshrc`: sheldon loads before `lib/aliases.zsh` so these aliases win. Oh My Zsh runs `compinit` once; add `fpath` entries before sheldon and never call `compinit` again. zoxide initializes last.
- `home/.config/sheldon/plugins.toml`: fzf-tab after Oh My Zsh and before autosuggestions; zsh-syntax-highlighting stays last. Run `sheldon lock` after editing.

## Checking changes

- Syntax: `zsh -n <file>` (including `bootstrap`).
- Startup time: `/usr/bin/time zsh -i -c exit` (about 0.15s). Put before/after numbers in the commit body for anything that affects it.

## Commits

Commit straight to `master`, one commit per logical change. Leave unrelated uncommitted changes alone.
