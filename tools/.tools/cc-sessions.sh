#!/bin/bash
###
# cc-sessions.sh — list Claude Code sessions
#
# Usage: cc-sessions.sh [-h] [-l] [-p <project>] [-f <filter>] [--projects-only] [--rm]
#   -h, --help            Show this help message
#   -l, --list            Output full session file paths only
#   -p, --project <str>   Filter by project path (partial match, case-insensitive)
#   -f, --filter <str>    Filter by session ID, name, or summary (case-insensitive)
#   --projects-only       Output only project paths (respects -p and -f filters)
#   --rm                  Remove matched sessions and their associated data (requires confirmation)
###

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
PROJECTS_DIR="$CLAUDE_DIR/projects"

FILES_ONLY=0
PROJECT_FILTER=""
FILTER=""
PROJECTS_ONLY=0
RM_SESSIONS=0

if [[ -t 1 ]]; then
  C_PROJECT=$'\033[1;36m'
  C_SESSION=$'\033[1;33m'
  C_LABEL=$'\033[0;90m'
  C_RESET=$'\033[0m'
else
  C_PROJECT=""
  C_SESSION=""
  C_LABEL=""
  C_RESET=""
fi

TERM_WIDTH=$(tput cols 2>/dev/null)
[[ "$TERM_WIDTH" =~ ^[0-9]+$ ]] && [[ "$TERM_WIDTH" -gt 0 ]] || TERM_WIDTH=80

while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--list)
      FILES_ONLY=1
      shift
      ;;
    -p|--project)
      [[ -z "$2" || "$2" == -* ]] && { echo "Error: --project requires a value" >&2; exit 1; }
      PROJECT_FILTER="$2"
      shift 2
      ;;
    -f|--filter)
      [[ -z "$2" || "$2" == -* ]] && { echo "Error: --filter requires a value" >&2; exit 1; }
      FILTER="$2"
      shift 2
      ;;
    --projects-only)
      PROJECTS_ONLY=1
      shift
      ;;
    --rm)
      RM_SESSIONS=1
      shift
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [-h] [-l] [-p <project>] [-f <filter>] [--projects-only] [--rm]"
      echo "  -h, --help            Show this help message"
      echo "  -l, --list            Output full session file paths only"
      echo "  -p, --project <str>   Filter by project path (partial match, case-insensitive)"
      echo "  -f, --filter <str>    Filter by session ID, name, or summary (case-insensitive)"
      echo "  --projects-only       Output only project paths (respects -p and -f filters)"
      echo "  --rm                  Remove matched sessions and their associated data (requires confirmation)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

[[ "$FILES_ONLY" -eq 1 && "$RM_SESSIONS" -eq 1 ]] && { echo "Error: --list and --rm cannot be used together" >&2; exit 1; }
[[ "$PROJECTS_ONLY" -eq 1 && "$FILES_ONLY" -eq 1 ]] && { echo "Error: --projects-only and --list cannot be used together" >&2; exit 1; }
[[ "$PROJECTS_ONLY" -eq 1 && "$RM_SESSIONS" -eq 1 ]] && { echo "Error: --projects-only and --rm cannot be used together" >&2; exit 1; }
[[ -d "$PROJECTS_DIR" ]] || { echo "Error: Claude projects directory not found: $PROJECTS_DIR" >&2; exit 1; }

declare -a rm_files=()
declare -a rm_labels=()
declare -A seen_projects=()
declare -a ordered_projects=()
first_project=1

for proj_dir in "$PROJECTS_DIR"/*/; do
  [[ -d "$proj_dir" ]] || continue
  proj_slug=$(basename "$proj_dir")
  header_printed=0

  for session_file in "$proj_dir"*.jsonl; do
    [[ -f "$session_file" ]] || continue

    project=$(grep -m1 '"cwd"' "$session_file" 2>/dev/null \
      | grep -o '"cwd":"[^"]*"' \
      | cut -d'"' -f4)
    [[ -z "$project" ]] && project="$proj_slug"

    session_id=$(basename "$session_file" .jsonl)

    name=$(grep -m1 '"type":"ai-title"' "$session_file" 2>/dev/null \
      | grep -o '"aiTitle":"[^"]*"' \
      | cut -d'"' -f4)

    summary=$(grep -m1 '"type":"last-prompt"' "$session_file" 2>/dev/null \
      | grep -o '"lastPrompt":"[^"]*"' \
      | cut -d'"' -f4)
    [[ -z "$summary" ]] && summary="No summary available"

    if [[ -n "$PROJECT_FILTER" ]] && [[ "${project,,}" != *"${PROJECT_FILTER,,}"* ]]; then
      continue
    fi

    if [[ -n "$FILTER" ]]; then
      filter_lower="${FILTER,,}"
      if [[ "${session_id,,}" != "$filter_lower" ]] && \
         [[ "${name,,}" != *"$filter_lower"* ]] && \
         [[ "${summary,,}" != *"$filter_lower"* ]]; then
        continue
      fi
    fi

    if [[ "$PROJECTS_ONLY" -eq 1 ]]; then
      if [[ -z "${seen_projects[$project]+x}" ]]; then
        seen_projects["$project"]=1
        ordered_projects+=("$project")
      fi
      continue
    fi

    if [[ "$RM_SESSIONS" -eq 1 ]]; then
      rm_files+=("$session_file")
      if [[ -n "$name" ]]; then
        rm_labels+=("$project  |  $session_id  ($name)")
      else
        rm_labels+=("$project  |  $session_id")
      fi
      continue
    fi

    if [[ "$FILES_ONLY" -eq 1 ]]; then
      echo "$session_file"
    else
      if [[ "$header_printed" -eq 0 ]]; then
        [[ "$first_project" -eq 0 ]] && echo ""
        local_header="── $project "
        pad_len=$(( TERM_WIDTH - ${#local_header} ))
        [[ $pad_len -lt 2 ]] && pad_len=2
        padding=$(printf "%${pad_len}s")
        padding="${padding// /─}"
        printf "%s%s%s%s\n" "$C_PROJECT" "$local_header" "$padding" "$C_RESET"
        header_printed=1
        first_project=0
      fi

      rel_path="projects/$proj_slug/$(basename "$session_file")"
      max_summary=$(( TERM_WIDTH - 15 ))
      disp_summary="$summary"
      [[ ${#disp_summary} -gt $max_summary ]] && disp_summary="${disp_summary:0:$max_summary}…"

      printf "  %s%s%s\n" "$C_SESSION" "$session_id" "$C_RESET"
      [[ -n "$name" ]] && printf "  %s  %-7s%s  %s\n" "$C_LABEL" "Name" "$C_RESET" "$name"
      printf "  %s  %-7s%s  %s\n" "$C_LABEL" "Summary" "$C_RESET" "$disp_summary"
      printf "  %s  %-7s%s  %s\n" "$C_LABEL" "File" "$C_RESET" "$rel_path"
    fi
  done
done

if [[ "$PROJECTS_ONLY" -eq 1 ]]; then
  for proj in "${ordered_projects[@]}"; do
    printf "%s%s%s\n" "$C_PROJECT" "$proj" "$C_RESET"
  done
fi

if [[ "$RM_SESSIONS" -eq 1 ]]; then
  count="${#rm_files[@]}"
  if [[ "$count" -eq 0 ]]; then
    echo "No sessions matched."
    exit 0
  fi

  echo "The following $count session(s) will be permanently removed:"
  for label in "${rm_labels[@]}"; do
    echo "  $label"
  done
  echo ""
  read -rp "Proceed? [y/N] " confirm
  [[ "${confirm,,}" != "y" ]] && { echo "Aborted."; exit 0; }

  removed=0
  for session_file in "${rm_files[@]}"; do
    uuid=$(basename "$session_file" .jsonl)
    rm -f "$session_file"
    rm -rf "$CLAUDE_DIR/file-history/$uuid"
    rm -rf "$CLAUDE_DIR/session-env/$uuid"
    rm -rf "$CLAUDE_DIR/tasks/$uuid"
    rm -f "$CLAUDE_DIR/security_warnings_state_$uuid.json"
    rm -f "$CLAUDE_DIR/debug/$uuid.txt"
    (( removed++ ))
  done
  echo "Removed $removed session(s)."
fi
