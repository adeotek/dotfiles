#!/bin/bash

###
# moca install script
#
# moca — MO Coding Agent: a minimal, token-efficient, provider-agnostic coding
# agent shipped as a single Go binary. The official installer downloads the
# release package for this platform, verifies it against the release's
# checksums.txt and installs the binary to ~/.local/bin (or next to an existing
# moca on PATH). Re-running it updates the installation in place.
# Homepage: https://github.com/adeotek/moca
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

# Resolve an existing moca, even when it is installed but not (yet) on PATH
MOCA_BIN="$(command -v moca 2>/dev/null)"
if [[ -z "$MOCA_BIN" && -x "$HOME/.local/bin/moca" ]]; then
  MOCA_BIN="$HOME/.local/bin/moca"
fi

# Install
cecho "cyan" "Installing [moca]..."

# Release packages cover every supported distro (static Go binary: linux/amd64
# and linux/arm64), so no per-distro branch is needed — reject anything else.
case $CURRENT_OS_ID in
  arch|debian|ubuntu|pop|fedora|redhat) ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  cecho "red" "[moca] installation requires curl or wget."
  return 1
fi

if [[ -n "$MOCA_BIN" ]]; then
  cecho "yellow" "[moca] is already present ($MOCA_BIN). Updating it..."
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  if ! (set -o pipefail; curl -fsSL https://raw.githubusercontent.com/adeotek/moca/main/install.sh | bash); then
    cecho "red" "[moca] installation failed."
    return 1
  fi
  cecho "green" "[moca] installation done."
else
  cecho "yellow" "DRY-RUN: curl -fsSL https://raw.githubusercontent.com/adeotek/moca/main/install.sh | bash"
fi

# Verify
if [[ "$DRY_RUN" -ne "1" ]]; then
  MOCA_BIN="$(command -v moca 2>/dev/null)"
  if [[ -z "$MOCA_BIN" && -x "$HOME/.local/bin/moca" ]]; then
    MOCA_BIN="$HOME/.local/bin/moca"
  fi
  if [[ -n "$MOCA_BIN" ]]; then
    cecho "green" "[moca] $("$MOCA_BIN" --version 2>/dev/null || echo 'installed') successfully."
  else
    cecho "red" "[moca] installation failed — 'moca' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: moca --version"
fi
