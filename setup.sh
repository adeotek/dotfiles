#!/bin/bash

###
# AdeoTEK dotfiles setup
###

# shellcheck disable=SC1091

# Init
if [[ -d "${0%/*}" ]]; then
  RDIR="$(cd "${0%/*}" && pwd)"
else
  RDIR="$PWD";
fi
CDIR="$RDIR/_scripts/core";

## Includes
source "$CDIR/_helpers.sh"
source "$CDIR/_options.sh"

# Globals
DEFAULT_MENU_OPTION="0"

function show_usage() {
  cecho "white" "Usage: $0 [OPTIONS]"
  cecho "white" "AdeoTEK dotfiles setup"
  cecho "white" "Options:"
  cecho "cyan" "  -b, --basic     Use the basic numeric prompts instead of the arrow-key interactive menus"
  cecho "cyan" "  --dry-run       Perform a dry run without making actual changes"
  cecho "cyan" "  -h, --help      Show this help and exit"
  cecho "cyan" "  -v, --verbose   Enable verbose output for debugging"
}

if [[ "$HELP_REQUESTED" -eq 1 ]]; then
  show_usage
  exit 0
fi

function select_packages_grid() {
  # Interactive multi-column checklist. Usage: select_packages_grid ALL_TASKS
  # Sets global SELECTED_PACKAGES on Enter; q/Esc/EOF cancel (exit 10).
  # ponytail: no paging/scroll — add when the task list exceeds one screen.
  local -n items=$1
  local total=${#items[@]}
  if [[ "$total" -eq 0 ]]; then
    SELECTED_PACKAGES=()
    return
  fi
  local max_len=0 name
  for name in "${items[@]}"
  do
    if [[ ${#name} -gt "$max_len" ]]; then
      max_len=${#name}
    fi
  done
  local cell_width=$(( max_len + 7 ))  # "[x] " + name + 3 trailing spaces
  local cols=$(( ${COLUMNS:-80} / cell_width ))
  if [[ "$cols" -lt 1 ]]; then cols=1; fi
  if [[ "$cols" -gt "$total" ]]; then cols=$total; fi
  local rows=$(( (total + cols - 1) / cols ))
  local -a checked=()
  local cursor=0 i row col idx mark line any warn_empty=0
  local REV=$'\e[7m' RESET=$'\e[0m'
  local hint="arrows: move | space: toggle | a: all/none | enter: confirm | q: cancel"

  _render_grid
  cecho "cyan" "$hint"
  while true
  do
    key="$(read_key)"
    case "$key" in
      up)
        if [[ "$cursor" -ge "$cols" ]]; then
          cursor=$(( cursor - cols ))
        fi
        ;;
      down)
        if (( cursor + cols < total )); then
          cursor=$(( cursor + cols ))
        fi
        ;;
      left)
        if (( cursor % cols > 0 )); then
          cursor=$(( cursor - 1 ))
        fi
        ;;
      right)
        if (( cursor % cols < cols - 1 && cursor + 1 < total )); then
          cursor=$(( cursor + 1 ))
        fi
        ;;
      space)
        if [[ "${checked[$cursor]:-}" == "1" ]]; then
          checked[cursor]=0
        else
          checked[cursor]=1
        fi
        ;;
      a|A)
        any=1
        for (( i = 0; i < total; i++ ))
        do
          if [[ "${checked[$i]:-}" != "1" ]]; then
            any=0
            break
          fi
        done
        for (( i = 0; i < total; i++ ))
        do
          checked[i]=$(( 1 - any ))
        done
        ;;
      enter)
        any=0
        for (( i = 0; i < total; i++ ))
        do
          if [[ "${checked[$i]:-}" == "1" ]]; then
            any=1
            break
          fi
        done
        if [[ "$any" -eq 1 ]]; then
          break
        fi
        warn_empty=1
        ;;
      q|Q|esc|eof)
        cecho "magenta" "Operation cancelled!"
        exit 10
        ;;
    esac
    printf '\e[%dA' "$(( rows + 1 ))"
    _render_grid
    if [[ "$warn_empty" -eq 1 ]]; then
      warn_empty=0
      cecho "red" "No packages selected. space toggles, q cancels."
    else
      cecho "cyan" "$hint"
    fi
  done
  SELECTED_PACKAGES=()
  for (( i = 0; i < total; i++ ))
  do
    if [[ "${checked[$i]:-}" == "1" ]]; then
      SELECTED_PACKAGES+=("${items[$i]}")
    fi
  done
}

# Top-level renderers for the interactive menus. They rely on dynamic scoping:
# they are only ever called while their menu's locals (cursor/rows/etc.) are in frame.
function _render_grid() {
  for (( row = 0; row < rows; row++ ))
  do
    line=""
    for (( col = 0; col < cols; col++ ))
    do
      idx=$(( row * cols + col ))
      if [[ "$idx" -ge "$total" ]]; then
        break
      fi
      mark=" "
      if [[ "${checked[$idx]:-}" == "1" ]]; then
        mark="x"
      fi
      if [[ "$idx" -eq "$cursor" ]]; then
        line+="${REV}$(printf '[%s] %-*s' "$mark" "$max_len" "${items[$idx]}")${RESET}   "
      else
        line+="$(printf '[%s] %-*s' "$mark" "$max_len" "${items[$idx]}")   "
      fi
    done
    printf '\r\033[2K%s\n' "$line"
  done
}

## Startup debug
cecho "blue" "Starting dotfiles setup ($DFS_ACTION)..."
decho "magenta" "Current OS: $CURRENT_OS_ID"
decho "magenta" "dotfiles root path: $RDIR"
decho "magenta" "core scripts path: $CDIR"

# Menu
## Display main menu
cecho "white" "Setup options:"

if [[ "$IS_TTY" -eq 1 && "$BASIC_MODE" -ne 1 ]]; then
  ## Arrow-key menu (single visual style: reverse-video cursor, painted by _render_menu)
  menu_cursor="$DEFAULT_MENU_OPTION"
  menu_rows=${#MENU_OPTION_KEYS[@]}
  function _render_menu() {
    for (( i = 0; i < menu_rows; i++ ))
    do
      key="${MENU_OPTION_KEYS[$i]}"
      if [[ "$key" == "$menu_cursor" ]]; then
        printf '\r\033[2K\e[7m %s %-2s %s\e[0m\n' "*" "$key" "${MENU_OPTIONS[$key]}"
      else
        printf '\r\033[2K  %-2s %s\n' "$key" "${MENU_OPTIONS[$key]}"
      fi
    done
  }
  _render_menu
  cecho "cyan" "arrows: move | enter: select | 0-3: quick-select | q: cancel"
  while true
  do
    key="$(read_key)"
    case "$key" in
      up)
        if [[ "$menu_cursor" == "q" ]]; then
          menu_cursor="3"
        elif [[ "$menu_cursor" != "0" ]]; then
          menu_cursor=$(( menu_cursor - 1 ))
        fi
        ;;
      down)
        if [[ "$menu_cursor" == "3" ]]; then
          menu_cursor="q"
        elif [[ "$menu_cursor" != "q" ]]; then
          menu_cursor=$(( menu_cursor + 1 ))
        fi
        ;;
      0|1|2|3)
        ## Quick-select by item number (same as basic mode)
        menu_cursor="$key"
        break
        ;;
      q|Q|esc|eof)
        menu_cursor="q"
        break
        ;;
      enter)
        break
        ;;
    esac
    printf '\e[%dA' "$(( menu_rows + 1 ))"
    _render_menu
    cecho "cyan" "arrows: move | enter: select | 0-3: quick-select | q: cancel"
  done
  SETUP_MODE="$menu_cursor"
  if [[ "$SETUP_MODE" == "q" ]]; then
    cecho "magenta" "Operation cancelled!"
    exit 10
  fi
else
  ## Numeric prompt (basic mode / non-TTY)
  for key in "${MENU_OPTION_KEYS[@]}"
  do
    if [[ "$key" == "$DEFAULT_MENU_OPTION" ]]; then
      cecho "yellow" " *[$key] ${MENU_OPTIONS[$key]}"
    else
      cecho "white" "  [$key] ${MENU_OPTIONS[$key]}"
    fi
  done
  cecho "yellow" -n "Please select setup mode (0-3, q) [$DEFAULT_MENU_OPTION]: "
  # Single keypress per iteration is intentional: options are one char (0-3, q), like read_yes_no.
  while true
  do
    if [[ "$IS_TTY" -eq 1 ]]; then
      key="$(read_key)"
      echo
      case "$key" in
        enter) SETUP_MODE="$DEFAULT_MENU_OPTION" ;;
        esc|eof) SETUP_MODE="q" ;;
        *) SETUP_MODE="$key" ;;
      esac
    else
      SETUP_MODE=""
      if ! IFS= read -r SETUP_MODE; then
        cecho "magenta" "Operation cancelled!"
        exit 10
      fi
      if [[ -z "$SETUP_MODE" ]]; then
        SETUP_MODE="$DEFAULT_MENU_OPTION"
      fi
      SETUP_MODE="${SETUP_MODE//[[:space:]]/}"
    fi
    if [[ "$SETUP_MODE" == "q" || "$SETUP_MODE" == "Q" ]]; then
      cecho "magenta" "Operation cancelled!"
      exit 10
    fi
    case $SETUP_MODE in
      0|1|2|3) break ;;
      *) cecho "red" "Invalid option selection: $SETUP_MODE" ;;
    esac
    cecho "yellow" -n "Please select setup mode (0-3, q) [$DEFAULT_MENU_OPTION]: "
  done
fi

case $SETUP_MODE in
  0)
    SELECTED_PACKAGES=()
    cecho "yellow" "The available packages are:"
    if [[ "$IS_TTY" -eq 1 && "$BASIC_MODE" -ne 1 ]]; then
      select_packages_grid ALL_TASKS
    else
      mapfile -t TASK_LINES < <(for i in "${!ALL_TASKS[@]}"; do printf '[%d] %-14s  \n' "$i" "${ALL_TASKS[$i]}"; done | column -c "${COLUMNS:-80}")
      for line in "${TASK_LINES[@]}"
      do
        cecho "cyan" "$line"
      done
      cecho "cyan" "[q] Cancel and exit"
      declare -A SEEN_IDS=()  # declared once — reused across input retries
      while true
      do
        cecho "yellow" -n "Please input the selected packages IDs separated by comma: "
        read -r TASKS_IDS
        if [[ "$TASKS_IDS" == "q" || "$TASKS_IDS" == "Q" ]]; then
          cecho "magenta" "Operation cancelled!"
          exit 10
        fi
        if [[ -z "$TASKS_IDS" ]]; then
          cecho "magenta" "No packages selected. Operation cancelled!"
          exit 10
        fi
        IFS=',' read -ra SELECTED_INDICES <<< "$TASKS_IDS"
        SELECTED_PACKAGES=()
        INVALID_ID=0
        for id in "${SELECTED_INDICES[@]}"
        do
          id="${id//[[:space:]]/}"  # Trim whitespace from $id
          if [[ -z "$id" ]]; then
            continue  # Ignore empty entries (e.g. trailing comma)
          fi
          if ! [[ "$id" =~ ^[0-9]+$ ]] || (( id >= ${#ALL_TASKS[@]} )); then
            cecho "red" "Invalid package id: [$id]"
            INVALID_ID=1
            break
          fi
          if [[ -n "${SEEN_IDS[$id]}" ]]; then
            continue  # Skip duplicate ids
          fi
          SEEN_IDS[$id]=1
          SELECTED_PACKAGES+=("${ALL_TASKS[$id]}")
        done
        if [[ "$INVALID_ID" -eq "1" ]]; then
          cecho "yellow" "Please try again."
          continue
        fi
        if [[ "${#SELECTED_PACKAGES[@]}" -eq 0 ]]; then
          cecho "red" "No valid package ids provided."
          continue
        fi
        break
      done
    fi
    ;;
  1)
    SELECTED_PACKAGES=("${MINIMAL_TASKS[@]}")
    ;;
  2)
    SELECTED_PACKAGES=("${CONSOLE_TASKS[@]}")
    cecho "yellow" "Extra packages (${#CONSOLE_EXTRA_TASKS[@]}):"
    mapfile -t EXTRA_LINES < <(printf '%s\n' "${CONSOLE_EXTRA_TASKS[@]}" | column -c "${COLUMNS:-80}")
    for line in "${EXTRA_LINES[@]}"
    do
      cecho "cyan" "$line"
    done
    read_yes_no "Do you want to include the extra packages? [y/N]: " "n"
    if [[ "$REPLY_YN" == "y" ]]; then
      SELECTED_PACKAGES=("${ALL_CONSOLE_TASKS[@]}")
    fi
    ;;
  3)
    SELECTED_PACKAGES=("${DESKTOP_TASKS[@]}")
    cecho "yellow" "Extra packages (${#DESKTOP_EXTRA_TASKS[@]}):"
    mapfile -t EXTRA_LINES < <(printf '%s\n' "${DESKTOP_EXTRA_TASKS[@]}" | column -c "${COLUMNS:-80}")
    for line in "${EXTRA_LINES[@]}"
    do
      cecho "cyan" "$line"
    done
    read_yes_no "Do you want to include the extra packages? [y/N]: " "n"
    if [[ "$REPLY_YN" == "y" ]]; then
      SELECTED_PACKAGES=("${ALL_DESKTOP_TASKS[@]}")
    fi
    ;;
esac

if [[ -z "${SELECTED_PACKAGES[*]}" ]]; then
  cecho "magenta" "No package selected. Operation cancelled!"
  exit 10
fi

cecho "white" "The following packages will be installed/set up:"
aecho -s SELECTED_PACKAGES "- " "yellow" "white"
read_yes_no "Please confirm package selection [Y/n]: " "y"
if [[ "$REPLY_YN" != "y" ]]; then
  cecho "magenta" "Operation cancelled!"
  exit 10
fi

# System update
if [[ "$DRY_RUN" -ne "1" ]]; then
  source "$CDIR/system-update.sh"
else
  cecho "yellow" "Dry run mode enabled. System update will be skipped."
fi

# Main
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg_task_type="${TASK_TYPES["$pkg"]}"
  if [[ -n "${TASK_ARGS[$pkg]}" ]]; then
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"" ${TASK_ARGS[$pkg]}"
    # shellcheck disable=SC2086  # intentional word-split to pass multiple flags
    # shellcheck source=/dev/null
    source "$CDIR/$pkg-$pkg_task_type.sh" ${TASK_ARGS[$pkg]}
  else
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"""
    # shellcheck source=/dev/null
    source "$CDIR/$pkg-$pkg_task_type.sh"
  fi
done

## End
cecho "blue" "DONE!"
