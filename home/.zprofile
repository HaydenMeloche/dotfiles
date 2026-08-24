# Homebrew must be available before shell configuration is loaded.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Keep credentials and machine-specific exports in ~/.zshlocal, never here.
