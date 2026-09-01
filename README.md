# Dotfiles

This repo represents my personal development setup built in a infrastructure-as-code style of repository. I use it to centrally store as many configs as possible and keep them versioned for debugging and sharing purposes.


## Install

```sh
git clone git@github.com:HaydenMeloche/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap
```

Then set your Git identity in `~/.gitconfig.local`, add your SSH key and `~/.ssh/config`, and create `~/.zshlocal` for private environment variables. In Karabiner-Elements, enable **Caps Lock to Hyper** from **Complex Modifications**. Use `dotfiles-update` later to update the repository, packages, and shell plugins.

## What is configured

- `Brewfile` — Homebrew command-line tools and desktop applications.
- `bootstrap` — the main installer: installs Homebrew packages and developer tools, applies macOS defaults, and creates configuration symlinks.
- `bin/dotfiles-update` — updates this repository, Homebrew packages, and Sheldon plugins.
- `scripts/install-{nvm,sdkman,codex,claude}` — install NVM, SDKMAN!, Codex, and Claude Code if they are not already available.
- `scripts/macos-defaults` — Dark Mode, keyboard and scrolling preferences, Dock layout, Finder settings, and trackpad click behavior.
- `scripts/clone-repos` and `repos.tsv` — clone the listed repositories into `~/code` (or `$CODE_DIR`), without replacing existing directories.

## Shell and terminal

- `home/.zprofile` — Homebrew and Docker CLI environment setup.
- `home/.zshrc` — shell defaults, PATH entries, NVM, SDKMAN!, Sheldon, direnv, fzf, Herdr tab naming, and loading of private local settings.
- `lib/aliases.zsh` — common shell and Git aliases plus `killport`.
- `lib/lscolors.zsh` — file-listing and completion colours.
- `lib/smartdots.zsh` — expands repeated `.` keystrokes into parent-directory navigation.
- `home/.config/sheldon/plugins.toml` and `prompt/spaceship.zsh` — Zsh plugin list and the Spaceship prompt loader.
- `home/.tmux.conf` — `Ctrl-A` prefix, vim-style pane navigation, mouse support, larger history, and macOS clipboard copying.
- `home/.config/ghostty/config` — GitHub Dark Dimmed theme and FiraCode Nerd Font terminal settings.

## Editors and desktop automation

- `home/.config/Code/User/settings.json` — VS Code editor, autosave, appearance, excluded-file, and zoom preferences.
- `home/.config/nvim/init.lua` — Neovim Treesitter and rendered-Markdown plugins.
- `home/.config/karabiner/assets/complex_modifications/caps_lock_to_hyper.json` — maps Caps Lock to Hyper/Super (`Control-Option-Shift-Command`) when held and Escape when tapped. Enable **Caps Lock to Hyper** in Karabiner-Elements after bootstrapping.
- `home/.hammerspoon/init.lua` — uses the Hyper modifier supplied by Karabiner: Hyper-1 through 4 open Ghostty, Firefox, Slack, and IntelliJ IDEA; Hyper-R reloads Hammerspoon.

## Git, SSH, and coding agents

- `home/.gitconfig` — Git defaults, aliases, global ignores, SSH GitHub URL rewriting, and a local identity include.
- `home/.gitignore_global` — ignores common editor, environment, certificate, and signing-key files across repositories.
- `home/.gitconfig.local.example` — template for the untracked local Git identity.
- `home/.ssh/config.example` — template for the untracked SSH GitHub host configuration.
- `home/.codex/config.toml` — Codex model, permissions, plugins, trusted projects, and hook state.
- `home/.codex/hooks.json` and `home/.codex/herdr-agent-state.sh` — report Codex session state to Herdr.
- `home/.codex/skills/pine-ship` — personal Codex skill for safely preparing and opening Pine pull requests.
- `home/.claude/settings.json` and `home/.claude/hooks/herdr-agent-state.sh` — Claude Code display settings and a Herdr SessionStart hook.
- `home/.config/herdr/config.toml` — Herdr terminal theme, UI, status indicators, sound, and toast delivery preferences.

## Local-only settings

- `~/.zshlocal` for private shell variables.
- `~/.gitconfig.local` for Git identity.
- `~/.ssh/config` and SSH keys for SSH configuration and credentials.
- Codex and Claude authentication, session history, caches, and per-machine trust settings.
