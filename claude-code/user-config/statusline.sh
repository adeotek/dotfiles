#!/usr/bin/env bash
# Claude Code status line script
# Segments (left to right, pipe-separated):
#   [cyan] cwd  |  [magenta] git branch  |  [blue] model  |  [green/yellow/red] context

# ANSI color codes
CYAN='\033[36m'
MAGENTA='\033[35m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'
DIM='\033[2m'

# Read JSON from stdin
input=$(cat)

# --- Parse with jq (Linux) ---
cwd=$(echo "$input"         | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"       | jq -r '.model.display_name // ""')
ctx_size=$(echo "$input"    | jq -r '.context_window.context_window_size // 0')
ctx_used=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')

# --- Shorten home directory ---
home_prefix="$HOME"
if [[ "$cwd" == "$home_prefix"* ]]; then
  cwd="~${cwd#$home_prefix}"
fi

# --- Git branch (from cwd, skip optional locks) ---
git_branch=""
if command -v git >/dev/null 2>&1; then
  # Resolve the actual directory (cwd may start with ~)
  real_dir="${cwd/#\~/$HOME}"
  if [[ -d "$real_dir" ]]; then
    git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" symbolic-ref --short HEAD 2>/dev/null \
                 || GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" rev-parse --short HEAD 2>/dev/null)
  fi
fi

# --- Format context window size as K ---
format_k() {
  local n="$1"
  if (( n >= 1000 )); then
    # Use awk for portable float formatting
    printf "%s" "$(awk -v n="$n" 'BEGIN { v=n/1000; printf "%.1fK", v }')"
  else
    printf "%s" "$n"
  fi
}

ctx_size_fmt=$(format_k "$ctx_size")

# --- Build context segment ---
if [[ -z "$ctx_used" ]]; then
  # No API call yet
  ctx_color="$GREEN"
  ctx_str="ctx: -- / ${ctx_size_fmt} tokens"
else
  # Round to one decimal
  ctx_used_fmt=$(awk -v p="$ctx_used" 'BEGIN { printf "%.1f", p }')
  ctx_str="ctx: ${ctx_used_fmt}% / ${ctx_size_fmt} tokens"
  # Color based on threshold
  ctx_int=$(awk -v p="$ctx_used" 'BEGIN { printf "%d", int(p) }')
  if (( ctx_int >= 80 )); then
    ctx_color="$RED"
  elif (( ctx_int >= 50 )); then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
fi

# --- Assemble status line ---
sep="${DIM} | ${RESET}"

out=""
out+=$(printf "${CYAN}%s${RESET}" "$cwd")

if [[ -n "$git_branch" ]]; then
  out+="${sep}"
  out+=$(printf "${MAGENTA}%s${RESET}" "$git_branch")
fi

if [[ -n "$model" ]]; then
  out+="${sep}"
  out+=$(printf "${BLUE}%s${RESET}" "$model")
fi

out+="${sep}"
out+=$(printf "${ctx_color}%s${RESET}" "$ctx_str")

printf "%b\n" "$out"
