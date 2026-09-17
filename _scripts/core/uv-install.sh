#!/bin/bash

###
# uv (Python package manager) install script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# uv installs into ~/.local/bin, which may not be on PATH in the current session
# (fresh LXCs and root profiles often lack it; the installer only edits rc files)
if [[ -x "$HOME/.local/bin/uv" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install
cecho "cyan" "Installing [uv]..."

if command -v uv >/dev/null 2>&1; then
  cecho "yellow" "[uv] is already present."
else
  execute_command "set -o pipefail && curl -LsSf https://astral.sh/uv/install.sh | sh" "[uv] installation done."
fi
