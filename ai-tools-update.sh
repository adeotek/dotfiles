#!/bin/bash

###
# Update AI tools (claude, opencode, pi, graphify, rtk) and their plugins/extensions
# Usage: ./ai-tools-update.sh [--dry-run]
###

DRY_RUN="0"
[[ "$1" == "--dry-run" ]] && DRY_RUN="1"

FAILED=()

# run "<tool>" cmd args... — prints and runs the command, records failures
run() {
  local tool="$1"
  shift
  echo "  \$ $*"
  [[ "$DRY_RUN" -eq "1" ]] && return 0
  "$@" || { echo "  !! failed: $*"; FAILED+=("$tool: $*"); }
}

has() { command -v "$1" >/dev/null 2>&1; }

section() { echo; echo "==> $1"; }

if has claude; then
  section "claude"
  run claude claude update
  run claude claude plugin marketplace update
  if has jq; then
    while IFS= read -r plugin; do
      run claude claude plugin update "$plugin"
    done < <(claude plugin list --json 2>/dev/null | jq -r '.[].id')
  else
    echo "  jq not found — skipping plugin updates"
  fi
fi

if has opencode; then
  section "opencode"
  run opencode opencode upgrade
  run opencode opencode plugin update
fi

if has pi; then
  section "pi"
  run pi pi update --all
fi

if has graphify; then
  section "graphify"
  if has uv; then
    run graphify uv tool upgrade graphifyy
  else
    echo "  uv not found — skipping package upgrade"
  fi
fi

if has rtk; then
  section "rtk"
  if has brew; then
    run rtk brew upgrade rtk
  else
    echo "  brew not found — skipping"
  fi
fi

echo
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "Failures:"
  printf '  - %s\n' "${FAILED[@]}"
  exit 1
fi
echo "AI tools update done."
