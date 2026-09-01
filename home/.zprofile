# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/hayden/.docker/bin"
# End of Docker Desktop section.

# Homebrew must be available before shell configuration is loaded.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Keep credentials and machine-specific exports in ~/.zshlocal, never here.
