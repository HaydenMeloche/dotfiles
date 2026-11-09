# Dotfiles

This repo represents my personal development setup built in an infrastructure-as-code style of repository. I use it to centrally store as many configs as possible and keep them versioned for debugging and sharing purposes.


## Install

```sh
git clone git@github.com:HaydenMeloche/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap
```
The installation script symlinks the files in this repo to the locations that their applications expect their configs to live. For example `$repo_dir/home/.zshrc` (the file in this repo) will be symlinked to `~/.zshrc`. Any direct config updates in the future to `~/.zshrc` is updating the git-versioned file in this repo. Files that apps write machine state into (`~/.codex/config.toml`, `~/.gitconfig.local`, `~/.ssh/config`) are copied once instead.

Once the script is complete, set your Git identity in `~/.gitconfig.local` and add your SSH key to `~/.ssh/config`. A `~/.zshlocal` file is created for private environment variables.

I never use caps lock, therefore I remap it to a "super" shortcut through Karabiner. I do this to achieve my window-tiling style quick access keys for example `CAPS + 1` opening/focusing Ghostty.
If you want to replicate this, open Karabiner-Elements and enable **Caps Lock to Hyper** from **Complex Modifications**.

Use `dotfiles-update` later to update the repository, packages, and shell plugins.

## What is configured

- `Brewfile` — Homebrew command-line tools and desktop applications.
- `bootstrap` — the main installer: installs Homebrew packages and developer tools, applies macOS defaults, and creates configuration symlinks.
- `bin/dotfiles-update` — updates this repository, Homebrew packages, and Sheldon plugins.
- `scripts/install-{nvm,sdkman,codex,claude}` — install NVM, SDKMAN!, Codex, and Claude Code if they are not already available.
- `scripts/macos-defaults` — Dark Mode, keyboard and scrolling preferences, Dock layout, Finder settings, and trackpad click behavior.
- `scripts/clone-repos` — clone the repositories listed in `~/.repos.tsv` (or `$REPOS_FILE`) into `~/code` (or `$CODE_DIR`), without replacing existing directories. `repos.tsv.example` shows the format.

## Shell and terminal

- `home/.zprofile` — Homebrew and Docker CLI environment setup.
- `home/.zshrc` — shell defaults, PATH entries, NVM, SDKMAN!, Sheldon, direnv, fzf, Herdr tab naming, and loading of private local settings.
- `lib/aliases.zsh` — common shell and Git aliases plus `killport`.
- `lib/lscolors.zsh` — file-listing and completion colours.
- `lib/smartdots.zsh` — expands repeated `.` keystrokes into parent-directory navigation.
- `home/.config/sheldon/plugins.toml` and `prompt/spaceship.zsh` — Zsh plugin list and the Spaceship prompt loader.
- `home/.config/ghostty/config` — TokyoNight theme, FiraCode Nerd Font, and Option as Alt.
- `home/.config/rex/init.lua` and `home/.config/rex/rex_open.lua` — Rex terminal config and the rex-open picker (Alt-Cmd-O) for files, links and commands in a pane's output. Rex itself is installed from the Rex website, not Homebrew.

## Editors and desktop automation

- `home/.config/nvim/init.lua` — Neovim Treesitter and rendered-Markdown plugins, plus autocomplete when editing a command line opened with Ctrl-X Ctrl-E.

## Git, SSH, and coding agents

- `home/.gitconfig` — Git defaults, aliases, global ignores, SSH GitHub URL rewriting, and a local identity include.
- `home/.gitignore_global` — ignores common editor, environment, certificate, and signing-key files across repositories.
- `home/.gitconfig.local.example` — template for the untracked local Git identity.
- `home/.ssh/config.example` — template for the untracked SSH GitHub host configuration.
- `home/.codex/config.toml` — starting Codex config (model, permissions, plugins), copied to `~/.codex/config.toml` on first install. Codex keeps trusted projects and hook state in its own copy.
- `home/.codex/hooks.json` and `home/.codex/herdr-agent-state.sh` — report Codex session state to Herdr.
- `home/.claude/CLAUDE.md` — global Claude Code instructions: Rex sessions and panes, working style, code changes, Git and PRs, and writing.
- `home/.claude/settings.json` and `home/.claude/hooks/herdr-agent-state.sh` — Claude Code display settings and a Herdr SessionStart hook.
- `home/.config/herdr/config.toml` — Herdr terminal theme, UI, status indicators, sound, and toast delivery preferences.

## Coding agents in this repo

- `AGENTS.md` — notes for coding agents working on this repo: what must stay out of the public repo, how files are installed, and shell load order. `CLAUDE.md` imports it for Claude Code.

## Local-only settings

- `~/.zshlocal` for private shell variables.
- `~/.gitconfig.local` for Git identity.
- `~/.repos.tsv` for the list of repositories `scripts/clone-repos` clones.
- `~/.ssh/config` and SSH keys for SSH configuration and credentials.
- Codex and Claude authentication, session history, caches, and per-machine trust settings.
