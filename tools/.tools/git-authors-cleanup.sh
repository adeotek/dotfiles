#!/bin/bash
###
# git-authors-cleanup.sh — strip AI agent authors/co-authors from a git history
#
# Scans the current repository for commits authored, committed or co-authored by
# AI coding agents (Claude, GitHub Copilot, Codex/OpenAI, Cursor, Gemini, Devin,
# Aider, Codeium/Windsurf, Tabnine, Cody, Qodo, Jules), lists every match, and —
# only after an explicit confirmation — rewrites history with git-filter-repo so
# that:
#   - agent authors/committers become the identity in `git config user.name` /
#     `git config user.email`
#   - `Co-authored-by:` trailers naming an agent are deleted from the message
#
# Agents are matched on the commit identity (name + email) against a pattern
# list; an unusual human name can therefore show up as well — review the list
# before answering yes.
#
# Usage: git-authors-cleanup.sh [options]
#   -b, --backup-dir <path>
#                     Directory that receives a `git clone --mirror` backup
#                     taken right before the rewrite (created if missing).
#                     Without this option no backup is made and the rewritten
#                     history cannot be recovered.
#   -n, --dry-run     Scan, then print the rewrite plan and change nothing
#       --no-install  Never install missing dependencies (fail with instructions)
#   -v, --verbose     Show the generated mailmap/callback and tool output
#   -h, --help        Show this help and exit
#
# Prompts (single keypress on a TTY, typed line otherwise):
#   1. remove the agents from the history?
#        y / Y           rewrite the history
#        n / N / ESC / ENTER, or EOF
#                        leave the repository untouched
#   2. (after a successful rewrite, when a remote exists) push it?
#        y / Y           fetch, then `git push --force-with-lease` the current
#                        branch to every remote; tags follow with plain --force
#                        (their lease base was rewritten too, so a lease would
#                        always be rejected as stale)
#        n / N / ESC / ENTER, or EOF (default)
#                        push nothing; print the commands to run manually
#
# Safety invariants:
#   - Nothing is pushed unless you answer yes to the second prompt.
#   - With --backup-dir a mirror backup of the repository is created before the
#     rewrite and its path is printed; it is never deleted by this script.
#     Without it the rewrite happens with no way back.
#   - Refuses to run on a dirty working tree, mid-merge/rebase, or detached HEAD
#     with commits — a rewrite resets the working tree.
#   - filter-repo drops the `origin` remote after rewriting; it is restored.
#   - Exit codes: 0 = done or declined, 1 = error (including a push you asked
#     for that did not complete).
###
set -o pipefail

DRY_RUN=0
VV=0
NO_INSTALL=0
BACKUP_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--backup-dir)
      if [[ -z "$2" ]]; then
        echo "Error: --backup-dir requires a path" >&2
        exit 1
      fi
      BACKUP_DIR="$2"
      shift 2
      ;;
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-install)
      NO_INSTALL=1
      shift
      ;;
    -v|--verbose)
      VV=1
      shift
      ;;
    -h|--help)
      awk '/^###$/{n++; next} n==1{sub(/^# ?/, ""); print}' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (use --help)" >&2
      exit 1
      ;;
  esac
done

# Resolve --backup-dir now: the script later cd's into the repository root, so a
# relative path must be anchored to the directory the script was called from.
if [[ -n "$BACKUP_DIR" ]]; then
  # shellcheck disable=SC2088  # "~"/"~/" are matched literally and expanded to $HOME below
  if [[ "$BACKUP_DIR" == "~" ]]; then
    BACKUP_DIR="$HOME"
  elif [[ "$BACKUP_DIR" == "~/"* ]]; then
    BACKUP_DIR="$HOME/${BACKUP_DIR#\~/}"
  fi
  if [[ "$BACKUP_DIR" != /* ]]; then
    BACKUP_DIR="$PWD/$BACKUP_DIR"
  fi
  # Drop trailing slashes so the backup path never contains "//".
  while [[ "$BACKUP_DIR" == */ && "$BACKUP_DIR" != "/" ]]; do
    BACKUP_DIR="${BACKUP_DIR%/}"
  done
fi

# shellcheck disable=SC2034
CURRENT_OS_ID="$(awk -F= '/^ID=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release 2>/dev/null)"

PKG_INSTALL=""
FALLBACK_INSTALL=""
BACKUP_PATH=""

# Agent identities, matched case-insensitively against "name <email>".
# `^` anchors the name (identities start with the author name), so an email
# containing e.g. "claude" in a domain is still matched by the domain pattern.
AGENT_PATTERNS=(
  'anthropic\.com'            # Claude / Claude Code
  '^claude'                   # "Claude", "Claude Code"
  'copilot'                   # GitHub Copilot, Copilot Autofix / coding agent
  'github-advanced-security'  # Copilot Autofix commits
  'openai\.com'               # Codex / OpenAI agents
  '^codex'
  'cursoragent|cursor\.com'   # Cursor agent
  'gemini'                    # Gemini, Gemini Code Assist
  'devin-ai'                  # Devin
  '^aider|aider@'             # Aider
  'codeium|windsurf'          # Codeium / Windsurf
  'tabnine'
  'sourcegraph|cody@'
  'qodo|codium'
  'jules@'                    # Google Jules
)

# ---------------------------------------------------------------- output ----

function cecho() {
  local color=$1
  shift

  case $1 in
    -n)
      local args="-n"
      shift
      ;;
    *) local args="";;
  esac

  local color_code=""
  case "$color" in
    "black") color_code="30" ;;
    "red") color_code="31" ;;
    "green") color_code="32" ;;
    "yellow") color_code="33" ;;
    "blue") color_code="34" ;;
    "magenta") color_code="35" ;;
    "cyan") color_code="36" ;;
    "white") color_code="37" ;;
  esac
  if [[ -z "$color_code" ]]; then
    # shellcheck disable=SC2086  # intentional: empty args must vanish, "-n" must pass as flag
    echo ${args:+$args} "$@"
  else
    # shellcheck disable=SC2086
    echo -e ${args:+$args} "\e[${color_code}m${*}\e[0m"
  fi
}

function vlog() {
  if [[ "$VV" -eq 1 ]]; then
    cecho "magenta" "  $*"
  fi
}

function section() {
  echo
  cecho "blue" "== $1 =="
}

function die() {
  cecho "red" "ERROR: $*"
  exit 1
}

# Same as die, but a --dry-run only warns: it changes nothing, so a state that
# would make a real rewrite destructive is not a reason to stop.
function enforce_or_warn() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    cecho "yellow" "  WARN (dry-run): $*"
  else
    die "$*"
  fi
}

# ----------------------------------------------------------- input helpers ----

# IS_TTY gates single-keypress reading; typed lines are used otherwise.
IS_TTY=0
if [[ -t 0 && -t 1 ]]; then
  IS_TTY=1
fi

function read_key() {
  # Reads one keypress; prints a canonical key name or the literal character.
  # A lone Esc costs one 100ms timeout window, arrow sequences are consumed.
  local key c1 c2
  if ! IFS= read -rsn1 key; then
    echo "eof"
    return
  fi
  case "$key" in
    $'\x1b')
      if IFS= read -rsn1 -t 0.1 c1 && [[ "$c1" == "[" || "$c1" == "O" ]]; then
        if IFS= read -rsn1 -t 0.1 c2; then
          case "$c1$c2" in
            "[A"|"OA") echo "up"; return ;;
            "[B"|"OB") echo "down"; return ;;
            "[C"|"OC") echo "right"; return ;;
            "[D"|"OD") echo "left"; return ;;
          esac
        fi
      fi
      echo "esc"
      ;;
    ""|$'\r'|$'\n') echo "enter" ;;
    " ") echo "space" ;;
    $'\x7f'|$'\b') echo "backspace" ;;
    *) echo "$key" ;;
  esac
}

function read_yes_no() {
  # Usage: read_yes_no "prompt" "default(y|n)"
  # Sets REPLY_YN to y|n|esc; anything but y means "do not touch the history".
  local prompt="$1"
  local default="${2:-n}"
  local key line
  while true; do
    cecho "yellow" -n "$prompt"
    if [[ "$IS_TTY" -eq 1 ]]; then
      key="$(read_key)"
      echo
    else
      key=""
      if ! IFS= read -r line; then
        REPLY_YN="esc"  # EOF: never interpret as yes
        return
      fi
      case "$line" in
        "") key="enter" ;;
        [yY]|[yY][eE][sS]) key="y" ;;
        [nN]|[nN][oO]) key="n" ;;
        $'\x1b') key="esc" ;;
        *) continue ;;
      esac
    fi
    case "$key" in
      y|Y) REPLY_YN="y"; return ;;
      n|N) REPLY_YN="n"; return ;;
      enter) REPLY_YN="$default"; return ;;
      esc|q|Q|eof) REPLY_YN="esc"; return ;;
    esac
  done
}

# ------------------------------------------------------------- utilities ----

function have() {
  command -v "$1" >/dev/null 2>&1
}

function require_git() {
  have git || die "git is not installed; it is required to run this script."
}

# Normalise "Name <email>" into ID_NAME / ID_EMAIL. Returns 1 when malformed.
function split_identity() {
  local raw="$1"
  # Kept in a variable: unescaped < and > are operators inside [[ ... ]] itself.
  local re='^[[:space:]]*(.*[^[:space:]])[[:space:]]*<([^>]+)>[[:space:]]*$'
  if [[ "$raw" =~ $re ]]; then
    ID_NAME="${BASH_REMATCH[1]}"
    ID_EMAIL="${BASH_REMATCH[2]}"
    return 0
  fi
  return 1
}

function is_agent() {
  local ident_lc="${1,,}"
  local pattern
  for pattern in "${AGENT_PATTERNS[@]}"; do
    if [[ "$ident_lc" =~ $pattern ]]; then
      return 0
    fi
  done
  return 1
}

function is_self() {
  local ident_lc="${1,,}"
  [[ -n "$CUR_EMAIL_LC" && "$ident_lc" == "$CUR_NAME_LC <$CUR_EMAIL_LC>" ]]
}

# ------------------------------------------------ repository and identity ----

function detect_repo() {
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) \
    || die "not inside a git working tree — run this script from the repository you want to clean."
  cd "$REPO_ROOT" || die "cannot enter [$REPO_ROOT]"
  if [[ "$(git rev-list --all --count)" -eq 0 ]]; then
    die "repository [$REPO_ROOT] has no commits; there is nothing to scan."
  fi
}

function detect_identity() {
  CUR_NAME=$(git config user.name)
  CUR_EMAIL=$(git config user.email)
  [[ -n "$CUR_NAME" ]] || die "git config user.name is empty; set it before running this script."
  [[ -n "$CUR_EMAIL" ]] || die "git config user.email is empty; set it before running this script."
  CUR_NAME_LC="${CUR_NAME,,}"
  CUR_EMAIL_LC="${CUR_EMAIL,,}"
}

# ------------------------------------------------------------------ scan ----

declare -A AGENT_AUTHORS=()
declare -A AGENT_COMMITTERS=()
declare -A AGENT_COAUTHORS=()
declare -a SELF_SKIPPED=()

# Shared collector for author/committer identities: the email field must be the
# counterpart of the name field (%an/%ae, %cn/%ce), never a mix of both.
function scan_identity_field() {
  local name_field="$1" email_field="$2" label="$3" target="$4" count ident
  local -n bucket="$target"
  while IFS=$'\t' read -r count ident; do
    [[ -n "$ident" ]] || continue
    split_identity "$ident" || continue
    ident="$ID_NAME <$ID_EMAIL>"
    is_agent "$ident" || continue
    if is_self "$ident"; then
      SELF_SKIPPED+=("$label: $ident")
      continue
    fi
    bucket["$ident"]=$(( ${bucket["$ident"]:-0} + count ))
  done < <(git log --all --format="%$name_field <%$email_field>" | awk 'NF { c[$0]++ } END { for (k in c) print c[k] "\t" k }')
}

function scan_authors() {
  scan_identity_field "an" "ae" "author" "AGENT_AUTHORS"
}

function scan_committers() {
  scan_identity_field "cn" "ce" "committer" "AGENT_COMMITTERS"
}

function scan_coauthors() {
  local count ident
  while IFS=$'\t' read -r count ident; do
    [[ -n "$ident" ]] || continue
    split_identity "$ident" || continue
    ident="$ID_NAME <$ID_EMAIL>"
    is_agent "$ident" || continue
    if is_self "$ident"; then
      SELF_SKIPPED+=("co-author: $ident")
      continue
    fi
    AGENT_COAUTHORS["$ident"]=$(( ${AGENT_COAUTHORS["$ident"]:-0} + count ))
  done < <(
    {
      git log --all --format='%b' \
        | tr -d '\r' \
        | grep -iE '^[[:space:]]*co-authored-by:' \
        | sed -E 's/^[^:]*:[[:space:]]*//' \
        || true
    } | awk 'NF { c[$0]++ } END { for (k in c) print c[k] "\t" k }'
  )
}

function scan_all() {
  AGENT_AUTHORS=()
  AGENT_COMMITTERS=()
  AGENT_COAUTHORS=()
  SELF_SKIPPED=()
  scan_authors
  scan_committers
  scan_coauthors
  FOUND_N=$(( ${#AGENT_AUTHORS[@]} + ${#AGENT_COMMITTERS[@]} + ${#AGENT_COAUTHORS[@]} ))
  return 0
}

function print_agents() {
  local kind count ident
  local -a rows=()
  for ident in "${!AGENT_AUTHORS[@]}"; do
    rows+=("author"$'\t'"${AGENT_AUTHORS[$ident]}"$'\t'"$ident")
  done
  for ident in "${!AGENT_COMMITTERS[@]}"; do
    rows+=("committer"$'\t'"${AGENT_COMMITTERS[$ident]}"$'\t'"$ident")
  done
  for ident in "${!AGENT_COAUTHORS[@]}"; do
    rows+=("co-author"$'\t'"${AGENT_COAUTHORS[$ident]}"$'\t'"$ident")
  done
  [[ ${#rows[@]} -gt 0 ]] || return 0
  while IFS=$'\t' read -r kind count ident; do
    printf '  %-10s %4s commit(s)  %s\n' "$kind" "$count" "$ident"
  done < <(printf '%s\n' "${rows[@]}" | sort -t$'\t' -k3,3 -k1,1)
}

# ----------------------------------------------------------- preflight ----

function preflight() {
  local changes
  # Abort (or, in a dry run that changes nothing, only warn) when the state makes
  # a rewrite destructive: a rewrite resets tracked files and moves refs, so a
  # detached HEAD would leave the checked-out commit on no branch.
  if ! git symbolic-ref -q HEAD >/dev/null; then
    enforce_or_warn "detached HEAD — check out a branch (e.g. git switch main) before rewriting."
  fi
  for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
    if [[ -e "$(git rev-parse --git-path "$marker")" ]]; then
      enforce_or_warn "a merge/rebase/cherry-pick is in progress ($marker); finish or abort it first."
    fi
  done
  changes=$(git status --porcelain 2>/dev/null)
  if [[ -n "$changes" ]]; then
    enforce_or_warn "working tree is not clean — commit or stash your changes first (a rewrite resets tracked files)."
  fi
  if [[ -n "$(git stash list 2>/dev/null)" ]]; then
    cecho "yellow" "  WARN: you have stashed changes; filter-repo rewrites all refs including the stash."
  fi
}

# ------------------------------------------------------- dependencies ----

# Resolve how to invoke filter-repo, in order of preference:
#   - the standalone `git-filter-repo` on PATH (Arch, Debian/Ubuntu, pipx, uv)
#   - git's exec-path, where Fedora/RHEL install the package entry point
#     (/usr/libexec/git-core/git-filter-repo); that file is NOT on PATH and is
#     only reachable as the `git filter-repo` subcommand
#   - Debian's module location
FILTER_REPO=""
declare -a FILTER_REPO_CMD=()

function find_filter_repo() {
  local candidate
  for candidate in "$(command -v git-filter-repo 2>/dev/null)" \
                   "$HOME/.local/bin/git-filter-repo" \
                   "$(git --exec-path 2>/dev/null)/git-filter-repo" \
                   "/usr/lib/python3/dist-packages/git_filter_repo.py"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      FILTER_REPO="$candidate"
      FILTER_REPO_CMD=("$candidate")
      return 0
    fi
  done
  # Last resort: usable only through git's subcommand lookup.
  if git filter-repo --version >/dev/null 2>&1; then
    FILTER_REPO="git filter-repo"
    FILTER_REPO_CMD=(git filter-repo)
    return 0
  fi
  return 1
}

function pkg_install_command() {
  case "$CURRENT_OS_ID" in
    arch) PKG_INSTALL="sudo pacman -S --noconfirm --needed git-filter-repo python" ;;
    debian|ubuntu|pop) PKG_INSTALL="sudo apt-get install -y git-filter-repo python3" ;;
    fedora|redhat) PKG_INSTALL="sudo dnf install -y git-filter-repo python3" ;;
    *) return 1 ;;
  esac
  return 0
}

function fallback_install() {
  # Package unavailable (e.g. older Debian, RHEL without EPEL) or no sudo:
  # install the single-file tool into the user's environment instead.
  if have pipx; then
    FALLBACK_INSTALL="pipx install git-filter-repo"
  elif have uv; then
    FALLBACK_INSTALL="uv tool install git-filter-repo"
  elif have python3; then
    FALLBACK_INSTALL="python3 -m pip install --user git-filter-repo"
  else
    return 1
  fi
  return 0
}

# Ensures python3 + git-filter-repo are usable. Returns 1 when unavailable.
function ensure_dependencies() {
  if find_filter_repo; then
    vlog "git-filter-repo: $FILTER_REPO"
    return 0
  fi

  if pkg_install_command; then
    :
  else
    cecho "red" "Unsupported OS: [${CURRENT_OS_ID:-unknown}] (supported: arch, debian|ubuntu|pop, fedora|redhat)"
    return 1
  fi
  fallback_install || cecho "yellow" "  no pipx/uv/python3 available for the fallback install"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    cecho "yellow" "  DRY-RUN: $PKG_INSTALL"
    [[ -n "$FALLBACK_INSTALL" ]] && cecho "yellow" "  DRY-RUN (if the package is missing): $FALLBACK_INSTALL"
    return 1
  fi
  if [[ "$NO_INSTALL" -eq 1 ]]; then
    cecho "red" "git-filter-repo is missing and --no-install was given."
    cecho "white" "  install it manually: $PKG_INSTALL"
    [[ -n "$FALLBACK_INSTALL" ]] && cecho "white" "  or: $FALLBACK_INSTALL"
    return 1
  fi

  section "dependencies"
  cecho "cyan" "Installing git-filter-repo via the [$CURRENT_OS_ID] package manager..."
  if bash -c "$PKG_INSTALL"; then
    cecho "green" "  package installation done."
  else
    cecho "yellow" "  package installation failed; trying the user-level fallback."
    if [[ -n "$FALLBACK_INSTALL" ]] && bash -c "$FALLBACK_INSTALL"; then
      cecho "green" "  fallback installation done."
    fi
  fi

  if find_filter_repo; then
    return 0
  fi
  cecho "red" "git-filter-repo is still not available."
  cecho "white" "  install it manually: $PKG_INSTALL"
  [[ -n "$FALLBACK_INSTALL" ]] && cecho "white" "  or: $FALLBACK_INSTALL"
  cecho "white" "  package already installed? reinstall it (a missing entry point is not"
  cecho "white" "  repaired by a plain install) or check: git filter-repo --version"
  return 1
}

# --------------------------------------------------------------- rewrite ----

MAILMAP_FILE=""
CALLBACK=""

function build_rewrite_inputs() {
  local ident email
  local -a identities=() emails=()

  # One entry per distinct identity, whether it showed up as author, committer
  # or co-author.
  mapfile -t identities < <(
    {
      for ident in "${!AGENT_AUTHORS[@]}"; do echo "$ident"; done
      for ident in "${!AGENT_COMMITTERS[@]}"; do echo "$ident"; done
      for ident in "${!AGENT_COAUTHORS[@]}"; do echo "$ident"; done
    } | sort -u
  )

  MAILMAP_FILE=$(mktemp "${TMPDIR:-/tmp}/agent-authors-mailmap.XXXXXX") \
    || die "cannot create a temporary file."

  for ident in "${identities[@]}"; do
    split_identity "$ident" || continue
    printf '%s <%s> %s <%s>\n' "$CUR_NAME" "$CUR_EMAIL" "$ID_NAME" "$ID_EMAIL" >> "$MAILMAP_FILE"
    emails+=("$ID_EMAIL")
  done

  local py_emails=""
  mapfile -t emails < <(printf '%s\n' "${emails[@]}" | sort -u)
  for email in "${emails[@]}"; do
    [[ -n "$email" ]] || continue
    py_emails+="    b\"${email//\"/\\\"}\","$'\n'
  done

  CALLBACK=$(cat <<'PY'
import re

_emails = [
__EMAILS__]
_pattern = re.compile(
    rb"^[ \t]*co-authored-by:[^\n]*<(?:" + b"|".join(re.escape(e) for e in _emails) + rb")>[^\n]*(?:\r?\n|$)",
    re.IGNORECASE | re.MULTILINE,
)
message = _pattern.sub(b"", message)
# Removing a trailer line must not leave a pile of blank lines behind.
return re.sub(rb"\n{2,}$", b"\n", message)
PY
)
  CALLBACK="${CALLBACK/__EMAILS__/$py_emails}"

  vlog "mailmap ($MAILMAP_FILE):"
  if [[ "$VV" -eq 1 ]]; then
    sed 's/^/    /' "$MAILMAP_FILE"
    cecho "magenta" "  message callback:"
    printf '%s\n' "$CALLBACK" | sed 's/^/    /'
  fi
}

function backup_repo() {
  BACKUP_PATH=""
  if [[ -z "$BACKUP_DIR" ]]; then
    cecho "yellow" "  no --backup-dir given: skipping the backup (this cannot be undone)."
    return 0
  fi
  mkdir -p "$BACKUP_DIR" || die "cannot create the backup directory [$BACKUP_DIR]."
  # Canonicalise now that the directory exists, so "sub/../bk" prints as "bk".
  BACKUP_DIR=$(cd "$BACKUP_DIR" && pwd) || die "cannot enter the backup directory [$BACKUP_DIR]."
  BACKUP_PATH="$BACKUP_DIR/$(basename "$REPO_ROOT")-$(date +%Y%m%d-%H%M%S).git"
  if git clone --mirror --quiet "$REPO_ROOT" "$BACKUP_PATH"; then
    cecho "green" "  backup: $BACKUP_PATH"
  else
    die "backup clone failed; nothing was rewritten."
  fi
}

function print_backup_plan() {
  if [[ -n "$BACKUP_DIR" ]]; then
    cecho "white" "  mirror backup would be created in: $BACKUP_DIR"
  else
    cecho "yellow" "  no backup would be created (--backup-dir not given)"
  fi
}

declare -A REMOTES=()

function capture_remotes() {
  local key url name
  while read -r key url; do
    name="${key#remote.}"
    name="${name%.url}"
    REMOTES["$name"]="$url"
  done < <(git config --get-regexp '^remote\..*\.url$' || true)
}

function restore_remotes() {
  local name
  local -a present=()
  mapfile -t present < <(git remote)
  for name in "${!REMOTES[@]}"; do
    if [[ " ${present[*]} " != *" $name "* ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        cecho "yellow" "  DRY-RUN: git remote add $name ${REMOTES[$name]}"
      elif git remote add "$name" "${REMOTES[$name]}"; then
        cecho "green" "  restored remote [$name]"
      else
        cecho "red" "  could not restore remote [$name]; re-add it manually: git remote add $name ${REMOTES[$name]}"
      fi
    fi
  done
}

function run_rewrite() {
  section "rewrite"
  cecho "yellow" "  This rewrites every ref in $REPO_ROOT; all commit SHAs from the first"
  cecho "yellow" "  touched commit onwards change. Nothing is pushed yet."

  backup_repo

  local -a cmd=("${FILTER_REPO_CMD[@]}" --force --mailmap "$MAILMAP_FILE" --message-callback "$CALLBACK")
  if [[ "$VV" -eq 1 ]]; then
    vlog "running: ${cmd[*]}"
  fi
  if ! "${cmd[@]}"; then
    if [[ -n "$BACKUP_PATH" ]]; then
      die "git-filter-repo failed. Your backup is at: $BACKUP_PATH"
    fi
    die "git-filter-repo failed, and no backup was taken (--backup-dir was not given)."
  fi
  restore_remotes
}

# ---------------------------------------------------------------- summary ----

function current_branch_ref() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  [[ -n "$branch" ]] || branch="HEAD"
  echo "$branch"
}

function has_tags() {
  # for-each-ref instead of `git tag | head -1`: no SIGPIPE under pipefail.
  [[ -n "$(git for-each-ref --count=1 --format='%(refname)' refs/tags)" ]]
}

function print_push_commands() {
  local name branch_ref tags_present
  branch_ref=$(current_branch_ref)
  tags_present=$(has_tags && echo yes)

  for name in "${!REMOTES[@]}"; do
    # filter-repo drops refs/remotes/* along with the `origin` remote; only the
    # URL is restored, so --force-with-lease would have no base ref to compare
    # against and the push fails with "(stale info)". Fetch first.
    cecho "white" "  git fetch $name"
    cecho "white" "  git push --force-with-lease $name $branch_ref"
    if [[ -n "$tags_present" ]]; then
      # Tags are their own lease base, and the rewrite already replaced them
      # locally, so --force-with-lease always reports "stale info" here.
      cecho "white" "  git push --force $name --tags"
    fi
  done
  if [[ ${#REMOTES[@]} -gt 0 ]]; then
    cecho "white" "  (the fetch is needed: the rewrite removed refs/remotes/*, which"
    cecho "white" "   --force-with-lease uses as its expected value)"
  else
    cecho "yellow" "  no remote configured; add one and push manually when ready."
  fi
}

function print_summary_notes() {
  if [[ -n "$BACKUP_PATH" ]]; then
    cecho "white" "  backup:  $BACKUP_PATH"
    cecho "white" "  restore: git clone $BACKUP_PATH <dir>"
  else
    cecho "yellow" "  no backup was taken (--backup-dir not given): the old history is gone."
  fi
  cecho "white" "  GitHub's contributor list is cached; re-check it after the push (up to ~24h)."
}

function print_next_steps() {
  section "next steps (not done by this script)"
  print_push_commands
  print_summary_notes
}

# Push the rewritten history: fetch first so --force-with-lease has a base ref,
# then force-push the current branch (and tags, when present) per remote.
function run_push() {
  local name branch_ref failed=0
  branch_ref=$(current_branch_ref)

  section "push"
  for name in "${!REMOTES[@]}"; do
    cecho "yellow" "  git fetch $name"
    if ! git fetch "$name"; then
      cecho "red" "  fetch from [$name] failed."
      failed=1
      continue
    fi
    cecho "yellow" "  git push --force-with-lease $name $branch_ref"
    if ! git push --force-with-lease "$name" "$branch_ref"; then
      cecho "red" "  push of [$branch_ref] to [$name] failed."
      failed=1
      continue
    fi
    if has_tags; then
      # Tags cannot be leased here: the rewrite already replaced them locally,
      # so --force-with-lease would always refuse with "stale info".
      cecho "yellow" "  git push --force $name --tags"
      if ! git push --force "$name" --tags; then
        cecho "red" "  push of the tags to [$name] failed."
        failed=1
      fi
    fi
  done
  return "$failed"
}

# ================================================================== main ====

trap '[[ -n "$MAILMAP_FILE" && -f "$MAILMAP_FILE" ]] && rm -f "$MAILMAP_FILE"' EXIT

cecho "blue" "git-authors-cleanup — removing AI agent authorship from git history"
if [[ "$DRY_RUN" -eq 1 ]]; then
  cecho "yellow" "DRY-RUN mode: nothing will be changed."
fi

require_git
detect_repo
detect_identity
cecho "white" "Repository: $REPO_ROOT"
cecho "white" "Replacement author: $CUR_NAME <$CUR_EMAIL>"

section "scan"
scan_all
if [[ "$FOUND_N" -eq 0 ]]; then
  cecho "green" "No AI agent authors, committers or co-authors found."
  if [[ ${#SELF_SKIPPED[@]} -gt 0 ]]; then
    while read -r entry; do
      cecho "white" "  skipped (your own identity): $entry"
    done < <(printf '%s\n' "${SELF_SKIPPED[@]}" | sort -u)
  fi
  exit 0
fi

cecho "white" "Found AI agent identities in the history of all refs:"
print_agents
if [[ ${#SELF_SKIPPED[@]} -gt 0 ]]; then
  while read -r entry; do
    cecho "white" "  skipped (your own identity): $entry"
  done < <(printf '%s\n' "${SELF_SKIPPED[@]}" | sort -u)
fi
echo
cecho "white" "Agents are matched on name/email patterns — check the list above."

read_yes_no "Remove all of them from the history? [y/N] " "n"
if [[ "$REPLY_YN" != "y" ]]; then
  cecho "white" "Nothing changed."
  exit 0
fi

preflight
capture_remotes

if ! ensure_dependencies; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    build_rewrite_inputs
    section "planned rewrite"
    [[ -n "$PKG_INSTALL" ]] && cecho "yellow" "  $PKG_INSTALL"
    cecho "yellow" "  git-filter-repo --force --mailmap <mailmap> --message-callback '<strip co-authored-by>'"
    print_backup_plan
    exit 0
  fi
  die "missing dependency: git-filter-repo (see the instructions above)."
fi

build_rewrite_inputs

if [[ "$DRY_RUN" -eq 1 ]]; then
  section "planned rewrite"
  cecho "yellow" "  ${FILTER_REPO_CMD[*]} --force --mailmap $MAILMAP_FILE --message-callback '<strip agent co-authors>'"
  print_backup_plan
  exit 0
fi

run_rewrite

section "verification"
scan_all
if [[ "$FOUND_N" -eq 0 ]]; then
  cecho "green" "No AI agent authors, committers or co-authors remain in the rewritten history."
else
  cecho "yellow" "Still present after the rewrite:"
  print_agents
  print_next_steps
  die "agent identities remain in the history — inspect the commits listed above."
fi

if [[ ${#REMOTES[@]} -gt 0 ]]; then
  echo
  read_yes_no "Push the rewritten history now? [y/N] " "n"
  if [[ "$REPLY_YN" == "y" ]]; then
    if run_push; then
      cecho "green" "  push done."
      echo
      print_summary_notes
      exit 0
    fi
    cecho "red" "  push did not complete; run the commands below manually."
    echo
    print_next_steps
    exit 1
  fi
  cecho "white" "Skipping the push."
  echo
fi

print_next_steps
exit 0
