# Hayden's dotfiles

Bootstraps a lot of the my favourite CLIs, Git alias and other configurations in the terminal while installing a few other apps I use.

## New Mac setup

```sh
git clone git@github.com:HaydenMeloche/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap
```

The bootstrap script installs Homebrew packages, creates symlinks for tracked settings, and preserves existing files with timestamped backups. It deliberately does not migrate SSH private keys, GPG keys, GitHub credentials, tokens, or work-only hosts.

On macOS, bootstrap also runs `scripts/macos-defaults` to apply the tracked Dark appearance, keyboard, Dock, Finder, and trackpad preferences. Run that script directly to reapply them later; it exits without changes on non-macOS systems.

## Package sources

`Brewfile` contains the Homebrew-managed command-line tools and apps. NVM is installed with its official per-user installer, and shell initialization is tracked; it intentionally has no default Node version because the current Mac has none configured. SDKMAN! is installed separately, but no SDK candidates are installed automatically. Codex and Claude Code are installed separately with their official standalone installers, which are the recommended macOS/Linux routes. Their portable preferences and Herdr SessionStart hooks are included; authentication, histories, sessions, caches, and machine-specific project trust are intentionally excluded. Python and VS Code extension lists are not currently managed because no portable active inventory was found.

The personal `pine-ship` Codex skill is also linked into `~/.codex/skills/pine-ship`; it prepares a reviewed Pine commit, push, and pull request, but refuses to push directly to `main` or `master`. Claude Code's portable display and hook settings are linked into `~/.claude`; its authentication, machine state, project trust, transcripts, and caches are deliberately excluded.

Hammerspoon is installed through Homebrew and its hotkey configuration is linked to `~/.hammerspoon/init.lua`. Karabiner-Elements turns Caps Lock into a Hyper/Super modifier (Control-Option-Shift-Command), while preserving Escape when Caps Lock is tapped. Hammerspoon then uses that modifier for the shortcuts: Hyper-1 through 4 launch Ghostty, Firefox, Slack, and IntelliJ IDEA, and Hyper-R reloads the configuration. After bootstrap, enable **Caps Lock to Hyper** from Karabiner-Elements → Complex Modifications → Add predefined rule.

After installation:

1. Update `~/.gitconfig.local` with your identity.
2. Create `~/.zshlocal` for tokens and machine-specific exports.

Run `dotfiles-update` to update packages and shell plugins later.

## Restore repositories

After adding your SSH key and authenticating to GitHub, I have the below script to mass clone repos

```sh
~/.dotfiles/scripts/clone-repos
```

It restores the repos listed in `repos.tsv` into `~/code`, and safely skips paths that already exist. Set `CODE_DIR` to use a different destination.
