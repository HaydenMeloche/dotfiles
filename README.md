# Hayden's dotfiles

Portable macOS shell, Git, tmux, editor, Ghostty, Herdr, Codex, and Homebrew configuration.

## New Mac setup

```sh
git clone git@github.com:HaydenMeloche/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap
```

The bootstrap script installs Homebrew packages, creates symlinks for tracked settings, and preserves existing files with timestamped backups. It deliberately does not migrate SSH private keys, GPG keys, GitHub credentials, tokens, or work-only hosts.

On macOS, bootstrap also runs `scripts/macos-defaults` to apply the tracked Dark appearance, keyboard, Dock, Finder, and trackpad preferences. Run that script directly to reapply them later; it exits without changes on non-macOS systems.

## Package sources

`Brewfile` contains the Homebrew-managed command-line tools and apps. NVM is installed with its official per-user installer, and shell initialization is tracked; it intentionally has no default Node version because the current Mac has none configured. SDKMAN! is installed separately, but no SDK candidates are installed automatically. Codex is installed separately with OpenAI's standalone installer, which is the official macOS/Linux route. Its portable preferences, GitHub plugin setting, and Herdr SessionStart hook are included; authentication, histories, sessions, caches, and machine-specific project trust are intentionally excluded. Python and VS Code extension lists are not currently managed because no portable active inventory was found.

The personal `pine-ship` Codex skill is also linked into `~/.codex/skills/pine-ship`; it prepares a reviewed Pine commit, push, and pull request, but refuses to push directly to `main` or `master`.

After installation:

1. Update `~/.gitconfig.local` with your identity.
2. Create `~/.zshlocal` for tokens and machine-specific exports.
3. Generate a new SSH key with `ssh-keygen -t ed25519` and add its public key to GitHub.
4. Sign in with `gh auth login`.

Run `dotfiles-update` to update packages and shell plugins later.

## Restore repositories

After adding your SSH key and authenticating to GitHub, clone the usual working repositories with:

```sh
~/.dotfiles/scripts/clone-repos
```

It restores the repos listed in `repos.tsv` into `~/code`, and safely skips paths that already exist. Set `CODE_DIR` to use a different destination.

## Cloud credentials

The AWS CLI is installed from `Brewfile`, but AWS configuration and SSO cache files are intentionally not migrated. Authenticate on the new Mac with your normal profile flow, for example `aws configure sso` followed by `aws sso login --profile <profile>`.
