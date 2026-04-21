#!/bin/bash
###
# cc-sessions.sh — list Claude Code sessions
#
# Usage: cc-sessions.sh [-l] [-f <filter>]
#   -l, --files         Output full session file paths only
#   -f, --filter <str>  Filter by project path or session name (case-insensitive)
###

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
PROJECTS_DIR="$CLAUDE_DIR/projects"

FILES_ONLY=0
FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--files)
      FILES_ONLY=1
      shift
      ;;
    -f|--filter)
      [[ -z "$2" || "$2" == -* ]] && { echo "Error: --filter requires a value" >&2; exit 1; }
      FILTER="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [-l] [-f <filter>]"
      echo "  -l, --files         Output full session file paths only"
      echo "  -f, --filter <str>  Filter by project path or session name (case-insensitive)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

[[ -d "$PROJECTS_DIR" ]] || { echo "Error: Claude projects directory not found: $PROJECTS_DIR" >&2; exit 1; }

for proj_dir in "$PROJECTS_DIR"/*/; do
  [[ -d "$proj_dir" ]] || continue
  proj_slug=$(basename "$proj_dir")

  for session_file in "$proj_dir"*.jsonl; do
    [[ -f "$session_file" ]] || continue

    project=$(grep -m1 '"cwd"' "$session_file" 2>/dev/null \
      | grep -o '"cwd":"[^"]*"' \
      | cut -d'"' -f4)
    [[ -z "$project" ]] && project="$proj_slug"

    session_name=$(grep -m1 '"type":"ai-title"' "$session_file" 2>/dev/null \
      | grep -o '"aiTitle":"[^"]*"' \
      | cut -d'"' -f4)
    [[ -z "$session_name" ]] && session_name="<untitled>"

    if [[ -n "$FILTER" ]]; then
      filter_lower="${FILTER,,}"
      if [[ "${project,,}" != *"$filter_lower"* ]] && [[ "${session_name,,}" != *"$filter_lower"* ]]; then
        continue
      fi
    fi

    if [[ "$FILES_ONLY" -eq 1 ]]; then
      echo "$session_file"
    else
      rel_path="projects/$proj_slug/$(basename "$session_file")"
      echo "$project | $session_name | $rel_path"
    fi
  done
done
