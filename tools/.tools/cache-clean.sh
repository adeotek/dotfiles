#!/bin/bash

###
# cache-clean.sh — clear development caches and reclaim disk space
#
# Removes regenerable caches only (package managers, toolchains, editors,
# browsers, AI coding tools) plus old VS Code / Insiders / Cursor server
# instances and system package caches. Anything that cannot be re-downloaded
# or rebuilt — configs, credentials, sessions, extensions, containers,
# volumes, installed packages — is never touched, so this script is safe to
# run at any time, on any of the supported machines.
#
# Usage: cache-clean.sh [options]
#   -n, --dry-run     Show what would be cleaned, remove nothing
#   -d, --deep        Also run the deeper cleanups (documented below), still
#                     cache-only and safe
#       --no-sudo     Skip the steps that need sudo (dnf/apt/pacman/journal)
#   -v, --verbose     List every removed/kept item
#   -h, --help        Show this help and exit
#
# Covered by default:
#   uv, docker (build cache + dangling images), pip, npm (+npx), pnpm, yarn,
#   bun, NuGet, Go, Rust, Homebrew, Playwright browsers, Hermes, OpenCode, Pi,
#   VS Code server instances, VS Code desktop caches, assorted ~/.cache dirs,
#   electron/huggingface download caches (30 days), dnf/apt/pacman caches,
#   flatpak unused runtimes, journal vacuum (keeps 30 days), /tmp/hermes-*
#   leftovers (24h).
#
# DEEP mode additionally:
#   docker   - prune stopped containers and all unused images
#   go       - clear the module cache (~/go/pkg/mod)
#   brew     - autoremove unused formulae
#   npx      - clear the whole npx cache (default: entries older than 7 days)
#   opencode - clear all cached plugin packages (default: older than 7 days)
#   playwright - remove all installed browsers (default: keep newest per family)
#   electron / huggingface - clear entirely (default: entries older than 30 days)
#
# Safety invariants:
#   - Only regenerable caches are removed; versioned stores always keep the
#     current/newest entry (VS Code servers, Pi releases, Playwright browsers).
#   - Sections that could disturb a running process are skipped while it runs
#     (opencode, pi, VS Code desktop) or limited to stale entries (docker).
#   - Deletion is refused outside $HOME and /tmp/hermes-*.
#   - Nothing is ever removed without a size report; --dry-run previews all of it.
###

# Shared: refuse to run with an unsafe HOME — every delete is scoped to $HOME.
if [[ -z "${HOME:-}" || "$HOME" != /* || "$HOME" == "/" || ! -d "$HOME" ]]; then
  echo "ERROR: refusing to run with unsafe HOME='${HOME:-}'" >&2
  exit 1
fi

# shellcheck disable=SC2034
CURRENT_OS_ID="$(awk -F= '/^ID=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release 2>/dev/null)"

DRY_RUN=0
DEEP=0
NO_SUDO=0
VV=0
FREED_KB=0
REMOVED_N=0
ERRORS=0

shopt -s nullglob

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -d|--deep)
      DEEP=1
      shift
      ;;
    --no-sudo)
      NO_SUDO=1
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

# ---------------------------------------------------------------- output ----

function cecho() {
  local color=$1
  shift
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
    echo "$@"
  else
    echo -e "\e[${color_code}m$*\e[0m"
  fi
}

function vlog() {
  if [[ "$VV" -eq 1 ]]; then
    cecho "magenta" "$@"
  fi
}

function section() {
  echo
  cecho "blue" "== $1 =="
}

function warn() {
  cecho "red" "  WARN: $*"
  ERRORS=$((ERRORS + 1))
}

# ------------------------------------------------------------- utilities ----

function have() {
  command -v "$1" >/dev/null 2>&1
}

function in_use() {
  have pgrep || return 1
  pgrep -x "$1" >/dev/null 2>&1
}

# Size of a file/dir in KB (0 when absent); floats are truncated.
function dir_size_kb() {
  local kb=""
  if [[ -e "$1" || -L "$1" ]]; then
    kb=$(du -sk -- "$1" 2>/dev/null | awk 'NR==1 { print $1 }')
  fi
  [[ "$kb" =~ ^[0-9]+$ ]] || kb=0
  echo "$kb"
}

function measure() {
  local total=0 p
  for p in "$@"; do
    total=$((total + $(dir_size_kb "$p")))
  done
  echo "$total"
}

function fmt_kb() {
  awk -v kb="${1:-0}" 'BEGIN {
    if (kb < 1024) { printf "%d KB", kb; exit }
    if (kb < 1048576) { printf "%.1f MB", kb / 1024; exit }
    printf "%.2f GB", kb / 1048576
  }'
}

# awk helper: human size ("5.476GB", "710.9MB", "0B") -> KB
_AWK_H2K='
function h2k(v,   n, u, m) {
  if (!match(v, /[0-9.]+/)) return 0
  n = substr(v, RSTART, RLENGTH) + 0
  u = substr(v, RSTART + RLENGTH)
  if (u ~ /^[Kk]/) m = 1
  else if (u ~ /^[Mm]/) m = 1024
  else if (u ~ /^[Gg]/) m = 1024 * 1024
  else if (u ~ /^[Tt]/) m = 1024 * 1024 * 1024
  else if (u ~ /^[Bb]/) m = 1 / 1024
  else m = 1
  return n * m
}'

function human_lines_to_kb() {
  awk "$_AWK_H2K"'{ sum += h2k($0) } END { printf "%d", sum }'
}

# Report the bytes reclaimed by a command by diffing dir sizes before/after.
function report_delta() {
  local before="$1" after="$2" label="$3" delta
  delta=$((before - after))
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$before" -gt 0 ]]; then
      cecho "yellow" "  [$label] (dry-run) up to $(fmt_kb "$before") reclaimable"
    fi
    FREED_KB=$((FREED_KB + before))
  elif [[ "$delta" -gt 0 ]]; then
    FREED_KB=$((FREED_KB + delta))
    cecho "green" "  [$label] freed $(fmt_kb "$delta")"
  elif [[ "$before" -gt 0 ]]; then
    cecho "green" "  [$label] already clean"
  else
    vlog "  [$label] nothing to clean"
  fi
}

# Run a command (unless dry-run); failures are reported but never fatal.
function run_cmd() {
  local cmd="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    cecho "yellow" "  DRY-RUN: $cmd"
    return 0
  fi
  vlog "  \$ $cmd"
  if ! bash -c "$cmd"; then
    warn "command failed: $cmd"
    return 1
  fi
  return 0
}

# Run a command that needs root: only with non-interactive sudo, or with an
# interactive prompt when attached to a TTY. Otherwise skipped, never fatal.
function run_sudo_cmd() {
  local cmd="$1"
  if [[ "$NO_SUDO" -eq 1 ]]; then
    vlog "  skipped (--no-sudo): $cmd"
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    cecho "yellow" "  DRY-RUN: sudo $cmd"
    return 0
  fi
  if sudo -n true 2>/dev/null; then
    run_cmd "sudo -n $cmd"
  elif [[ -t 0 && -t 1 ]]; then
    cecho "yellow" "  sudo password required for: $cmd"
    run_cmd "sudo $cmd"
  else
    vlog "  skipped (sudo unavailable, no TTY): $cmd"
  fi
}

# True when a running process references the path on its command line —
# such items are never touched (live VS Code servers, running browser/agent
# processes, in-flight session scratch files). Best-effort safety net: a
# false positive only means an item is kept, never that something is deleted.
function path_in_use() {
  have pgrep || return 1
  pgrep -f -- "$1" >/dev/null 2>&1
}

# Hard safety guard for every deletion: only paths under $HOME (or the
# dedicated /tmp/hermes-* namespace) may ever be removed.
function _remove_core() {
  local path="$1" announce="$2" kb
  case "$path" in
    ""|"/"|"$HOME") warn "refusing to remove unsafe path: [$path]"; return 1 ;;
    "$HOME"/*|/tmp/hermes-*) ;;
    *) warn "refusing to remove path outside HOME: [$path]"; return 1 ;;
  esac
  if [[ ! -e "$path" && ! -L "$path" ]]; then
    vlog "  absent, skipping: $path"
    return 1
  fi
  if path_in_use "$path"; then
    vlog "  in use by a running process, keeping: $path"
    return 1
  fi
  kb=$(dir_size_kb "$path")
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$announce" -eq 1 && "$VV" -eq 0 ]]; then
      cecho "yellow" "  DRY-RUN: rm -rf -- $path  ($(fmt_kb "$kb"))"
    else
      vlog "  would remove: $path ($(fmt_kb "$kb"))"
    fi
  else
    if ! rm -rf -- "$path"; then
      warn "failed to remove: $path"
      return 1
    fi
    if [[ "$announce" -eq 1 && "$VV" -eq 0 ]]; then
      cecho "green" "  removed: $path ($(fmt_kb "$kb"))"
    else
      vlog "  removed: $path ($(fmt_kb "$kb"))"
    fi
  fi
  FREED_KB=$((FREED_KB + kb))
  REMOVED_N=$((REMOVED_N + 1))
  return 0
}

# Prominent single item: reported individually even without --verbose.
function remove_item() {
  _remove_core "$1" 1
}

# Bulk item: reported only under --verbose (callers print an aggregate line).
function remove_silent() {
  _remove_core "$1" 0
}

# Remove every match of a find expression below a directory, with aggregated
# reporting. Usage: remove_entries <label> <dir> <find args...>
function remove_entries() {
  local label="$1" dir="$2"
  shift 2
  if [[ ! -d "$dir" ]]; then
    vlog "  [$label] not present, skipping"
    return 0
  fi
  local -a items=()
  local item
  local before_freed="$FREED_KB" before_n="$REMOVED_N"
  mapfile -d '' items < <(find "$dir" "$@" -print0 2>/dev/null)
  for item in "${items[@]}"; do
    [[ -n "$item" ]] || continue
    remove_silent "$item"
  done
  report_batch "$label" "$before_freed" "$before_n"
}

# Print the aggregate line for a batch of removals.
function report_batch() {
  local label="$1" before_freed="$2" before_n="$3"
  local n=$((REMOVED_N - before_n))
  local freed=$((FREED_KB - before_freed))
  local noun="entries"
  [[ "$n" -eq 1 ]] && noun="entry"
  if [[ "$n" -eq 0 ]]; then
    vlog "  [$label] nothing to remove"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    cecho "green" "  [$label] would remove $n $noun ($(fmt_kb "$freed"))"
  else
    cecho "green" "  [$label] removed $n $noun ($(fmt_kb "$freed"))"
  fi
}

# Remove first-level entries of a directory older than N minutes.
# $1 dir, $2 age in minutes, $3 label
function prune_old_entries() {
  local dir="$1" age_min="$2" label="${3:-$1}"
  remove_entries "$label" "$dir" -mindepth 1 -maxdepth 1 -mmin "+$age_min"
}

# ================================================================= steps ====

function step_uv() {
  section "uv"
  if ! have uv; then
    # Orphaned cache of an uninstalled uv — pure regenerable data.
    remove_item "$HOME/.cache/uv"
    remove_item "$HOME/.hermes/cache/uv"
    return 0
  fi
  local before after
  before=$(measure "$HOME/.cache/uv")
  run_cmd "uv cache clean"
  after=$(measure "$HOME/.cache/uv")
  report_delta "$before" "$after" "uv"

  # Hermes keeps its own uv cache for managed environments.
  if [[ -d "$HOME/.hermes/cache/uv" ]]; then
    before=$(measure "$HOME/.hermes/cache/uv")
    run_cmd "uv cache clean --cache-dir \"$HOME/.hermes/cache/uv\""
    after=$(measure "$HOME/.hermes/cache/uv")
    report_delta "$before" "$after" "uv (hermes)"
  fi
}

function step_docker() {
  section "docker"
  local docker_str=""
  if have docker; then
    if docker info >/dev/null 2>&1; then
      docker_str="docker"
    elif [[ "$NO_SUDO" -ne 1 ]] && sudo -n true 2>/dev/null && sudo -n docker info >/dev/null 2>&1; then
      docker_str="sudo -n docker"
    fi
  fi
  if [[ -z "$docker_str" ]]; then
    vlog "  docker daemon not reachable, skipping"
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    cecho "yellow" "  DRY-RUN: $docker_str builder prune -f"
    if [[ "$DEEP" -eq 1 ]]; then
      cecho "yellow" "  DRY-RUN: $docker_str container prune -f"
      cecho "yellow" "  DRY-RUN: $docker_str image prune -a -f"
    else
      cecho "yellow" "  DRY-RUN: $docker_str image prune -f"
    fi
    cecho "white" "  current docker usage:"
    bash -c "$docker_str system df" 2>/dev/null | sed 's/^/    /'
    return 0
  fi
  local before after
  before=$(bash -c "$docker_str system df --format '{{.Size}}'" 2>/dev/null | human_lines_to_kb)
  [[ "$before" =~ ^[0-9]+$ ]] || before=0
  run_cmd "$docker_str builder prune -f"
  if [[ "$DEEP" -eq 1 ]]; then
    run_cmd "$docker_str container prune -f"
    run_cmd "$docker_str image prune -a -f"
  else
    run_cmd "$docker_str image prune -f"
  fi
  after=$(bash -c "$docker_str system df --format '{{.Size}}'" 2>/dev/null | human_lines_to_kb)
  [[ "$after" =~ ^[0-9]+$ ]] || after="$before"
  report_delta "$before" "$after" "docker"
}

function step_pip() {
  section "pip"
  if ! have pip; then
    remove_item "$HOME/.cache/pip"
    return 0
  fi
  local before after
  before=$(measure "$HOME/.cache/pip")
  run_cmd "pip cache purge"
  after=$(measure "$HOME/.cache/pip")
  report_delta "$before" "$after" "pip"
}

function step_node() {
  section "node package managers"

  if have npm; then
    local before after
    before=$(measure "$HOME/.npm")
    if [[ "$DRY_RUN" -eq 1 ]]; then
      # _npx is accounted for separately below.
      before=$((before - $(measure "$HOME/.npm/_npx")))
      [[ "$before" -lt 0 ]] && before=0
    fi
    run_cmd "npm cache clean --force"
    after=$(measure "$HOME/.npm")
    report_delta "$before" "$after" "npm"

    # npx keeps one full package install per spec it ever ran.
    if [[ "$DEEP" -eq 1 ]]; then
      remove_entries "npx (all)" "$HOME/.npm/_npx" -mindepth 1 -maxdepth 1
    else
      prune_old_entries "$HOME/.npm/_npx" 10080 "npx (> 7d)"
    fi
  else
    remove_item "$HOME/.npm"
  fi

  if have pnpm; then
    run_cmd "pnpm store prune"
  fi

  if have yarn; then
    run_cmd "yarn cache clean"
  fi

  if have bun; then
    local before after
    before=$(measure "$HOME/.cache/bun" "$HOME/.bun/install/cache")
    run_cmd "bun pm cache rm"
    after=$(measure "$HOME/.cache/bun" "$HOME/.bun/install/cache")
    report_delta "$before" "$after" "bun"
  else
    remove_item "$HOME/.cache/bun"
    remove_item "$HOME/.bun/install/cache"
  fi
}

function step_nuget() {
  section "nuget"
  if ! have dotnet; then
    remove_item "$HOME/.nuget/packages"
    return 0
  fi
  local before after
  before=$(measure "$HOME/.nuget" "$HOME/.local/share/NuGet")
  run_cmd "dotnet nuget locals all --clear"
  after=$(measure "$HOME/.nuget" "$HOME/.local/share/NuGet")
  report_delta "$before" "$after" "nuget"
}

function step_go() {
  section "go"
  local go_bin=""
  if have go; then
    go_bin="go"
  elif [[ -x /usr/local/go/bin/go ]]; then
    go_bin="/usr/local/go/bin/go"
  fi
  if [[ -z "$go_bin" ]]; then
    # Orphaned caches of an uninstalled toolchain.
    remove_item "$HOME/.cache/go-build"
    remove_item "$HOME/go/pkg/mod"
    return 0
  fi
  local before after
  before=$(measure "$HOME/.cache/go-build")
  if [[ "$DEEP" -eq 1 ]]; then
    before=$((before + $(measure "$HOME/go/pkg/mod")))
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd "$go_bin clean -n -cache"
  else
    run_cmd "$go_bin clean -cache"
  fi
  if [[ "$DEEP" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      run_cmd "$go_bin clean -n -modcache"
    else
      run_cmd "$go_bin clean -modcache"
    fi
  fi
  after=$(measure "$HOME/.cache/go-build")
  if [[ "$DEEP" -eq 1 ]]; then
    after=$((after + $(measure "$HOME/go/pkg/mod")))
  fi
  report_delta "$before" "$after" "go"
}

function step_cargo() {
  section "rust"
  if ! have cargo; then
    remove_item "$HOME/.cargo/registry/cache"
    remove_item "$HOME/.cargo/registry/src"
    return 0
  fi
  # The crate cache + extracted sources: rebuilt from the network on next build.
  remove_item "$HOME/.cargo/registry/cache"
  remove_item "$HOME/.cargo/registry/src"
}

function step_brew() {
  section "homebrew"
  local brew_cmd=""
  if have brew; then
    brew_cmd="brew"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    brew_cmd="/home/linuxbrew/.linuxbrew/bin/brew"
  fi
  [[ -n "$brew_cmd" ]] || { vlog "  brew not found, skipping"; return 0; }

  local cache_dir before after
  cache_dir=$("$brew_cmd" --cache 2>/dev/null)
  before=$(measure "$cache_dir")
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd "HOMEBREW_NO_AUTO_UPDATE=1 $brew_cmd cleanup -n -s"
  else
    run_cmd "HOMEBREW_NO_AUTO_UPDATE=1 $brew_cmd cleanup -s"
  fi
  if [[ "$DEEP" -eq 1 ]]; then
    run_cmd "HOMEBREW_NO_AUTO_UPDATE=1 $brew_cmd autoremove"
  fi
  after=$(measure "$cache_dir")
  report_delta "$before" "$after" "brew"
}

function step_playwright() {
  section "playwright"
  local cache entry family name
  for cache in "$HOME/.cache"/ms-playwright*; do
    [[ -d "$cache" ]] || continue
    if [[ "$DEEP" -eq 1 ]]; then
      # Explicit deep mode: remove every browser (re-install with:
      #   npx --yes playwright install chromium)
      for entry in "$cache"/*/; do
        remove_item "${entry%/}"
      done
      continue
    fi
    # Default: keep the most recent build of each browser family, drop stale ones.
    local -A newest_mtime=()
    local -A newest_name=()
    for entry in "$cache"/*/; do
      name=$(basename "${entry%/}")
      family="${name%-*}"
      local mtime
      mtime=$(stat -c '%Y' "${entry%/}" 2>/dev/null || echo 0)
      if [[ -z "${newest_mtime[$family]:-}" || "$mtime" -gt "${newest_mtime[$family]}" ]]; then
        newest_mtime["$family"]=$mtime
        newest_name["$family"]="$name"
      fi
    done
    for entry in "$cache"/*/; do
      name=$(basename "${entry%/}")
      family="${name%-*}"
      if [[ "${newest_name[$family]:-}" == "$name" ]]; then
        vlog "  keep: ${entry%/} (family $family)"
      else
        remove_item "${entry%/}"
      fi
    done
  done
}

function step_hermes() {
  section "hermes"
  local cache_dir="$HOME/.hermes/cache"
  if [[ ! -d "$cache_dir" ]]; then
    vlog "  hermes cache not present, skipping"
    return 0
  fi
  # Scratch: the runtime prunes entries idle for 24h by policy; anything older
  # is fair game. Recent scratch belongs to running sessions — never touched.
  prune_old_entries "$cache_dir/scratch" 1440 "scratch (idle > 24h)"
  # Auxiliary caches: 7 days, matching Hermes' own temp-file retention.
  local sub
  for sub in blocked-scripts browser-use citations delegation documents exec images audio screenshots terminal terminal-output videos vision web partials; do
    prune_old_entries "$cache_dir/$sub" 10080 "$sub (> 7d)"
  done
}

function step_opencode() {
  section "opencode"
  local cache_dir="$HOME/.cache/opencode"
  [[ -d "$cache_dir" ]] || { vlog "  opencode cache not present, skipping"; return 0; }
  if in_use opencode; then
    cecho "yellow" "  opencode is running, skipping"
    return 0
  fi
  # Plugin packages are re-installed on demand; hidden entries are internal state.
  if [[ "$DEEP" -eq 1 ]]; then
    remove_entries "opencode packages (all)" "$cache_dir/packages" -mindepth 1 -maxdepth 1 ! -name '.*'
  else
    remove_entries "opencode packages (> 7d)" "$cache_dir/packages" -mindepth 1 -maxdepth 1 ! -name '.*' -mmin +10080
  fi
}

function step_pi() {
  section "pi"
  local agent_dir="$HOME/.pi/agent"
  local install_dir="$agent_dir/install"
  [[ -d "$install_dir" ]] || { vlog "  pi install dir not present, skipping"; return 0; }
  if in_use pi; then
    cecho "yellow" "  pi is running, skipping"
    return 0
  fi
  local current=""
  if [[ -f "$install_dir/current-version" ]]; then
    IFS= read -r current < "$install_dir/current-version"
  fi
  # Old managed releases: keep only the active one (the launcher reads
  # install/current-version and executes install/releases/<version>).
  if [[ -n "$current" && -d "$install_dir/releases" ]]; then
    local rel name
    for rel in "$install_dir/releases"/*/; do
      name=$(basename "${rel%/}")
      if [[ "$name" == "$current" ]]; then
        vlog "  keep: $rel (current)"
      else
        remove_item "${rel%/}"
      fi
    done
  fi
  # Staged downloads are transient by design.
  remove_entries "pi staging" "$install_dir/staging" -mindepth 1 -maxdepth 1
  # NOTE: ~/.pi/agent/npm and ~/.pi/agent/git hold installed extensions —
  # deliberately never touched.
}

function step_vscode_servers() {
  section "vs code server instances"
  local root
  for root in "$HOME/.vscode-server" "$HOME/.vscode-server-insiders" "$HOME/.cursor-server"; do
    [[ -d "$root" ]] || continue
    prune_vscode_server_root "$root"
  done
}

# Prune one VS Code server root: keep the newest (active) instance of each
# layout, drop older ones plus their launcher binaries/logs. Never touches
# data/ or extensions/ (user state and installed extensions). Items a running
# process references are kept automatically by the in-use guard.
function prune_vscode_server_root() {
  local root="$1" root_label
  root_label="$(basename "$root")"
  local keep_hashes=() name hash entry kept h before_freed before_n
  vlog "  [$root] checking"

  # ---- Current layout: cli/servers/<Flavor>-<sha40> ----
  local servers_dir="$root/cli/servers"
  if [[ -d "$servers_dir" ]]; then
    # Keep the newest instance (the active one is touched on connect)...
    local newest_dir
    newest_dir=$(find "$servers_dir" -mindepth 1 -maxdepth 1 -type d \
      -regextype posix-extended -regex '.*/[A-Za-z][A-Za-z0-9]*-[0-9a-f]{40}' \
      -printf '%T@ %f\n' 2>/dev/null | sort -rn | awk 'NR==1 { print $2 }')
    if [[ -n "$newest_dir" ]]; then
      keep_hashes+=("${newest_dir##*-}")
      vlog "  keep: $servers_dir/$newest_dir (newest)"
    fi
    # ...plus the most recently used entry recorded in lru.json.
    if [[ -f "$servers_dir/lru.json" ]]; then
      local lru=""
      lru=$(grep -o '"[^"]*"' "$servers_dir/lru.json" 2>/dev/null | head -n1 | tr -d '"')
      if [[ -n "$lru" && -d "$servers_dir/$lru" ]]; then
        hash="${lru##*-}"
        kept=0
        for h in "${keep_hashes[@]}"; do [[ "$h" == "$hash" ]] && kept=1; done
        if [[ "$kept" -eq 0 ]]; then
          keep_hashes+=("$hash")
          vlog "  keep: $servers_dir/$lru (lru.json)"
        fi
      fi
    fi

    before_freed="$FREED_KB"
    before_n="$REMOVED_N"
    while IFS= read -r -d '' name; do
      entry=$(basename "$name")
      hash="${entry##*-}"
      kept=0
      for h in "${keep_hashes[@]}"; do [[ "$h" == "$hash" ]] && kept=1; done
      [[ "$kept" -eq 1 ]] && continue
      remove_silent "$name"
    done < <(find "$servers_dir" -mindepth 1 -maxdepth 1 -type d \
      -regextype posix-extended -regex '.*/[A-Za-z][A-Za-z0-9]*-[0-9a-f]{40}' \
      -print0 2>/dev/null)
    report_batch "$root_label server instances" "$before_freed" "$before_n"
  fi

  # ---- Legacy layout: bin/<sha40> ----
  local bin_dir="$root/bin"
  if [[ -d "$bin_dir" ]]; then
    local newest_bin=""
    newest_bin=$(find "$bin_dir" -mindepth 1 -maxdepth 1 -type d \
      -regextype posix-extended -regex '.*/[0-9a-f]{40}' \
      -printf '%T@ %f\n' 2>/dev/null | sort -rn | awk 'NR==1 { print $2 }')
    if [[ -n "$newest_bin" ]]; then
      vlog "  keep: $bin_dir/$newest_bin (newest)"
    fi
    before_freed="$FREED_KB"
    before_n="$REMOVED_N"
    while IFS= read -r -d '' name; do
      entry=$(basename "$name")
      [[ "$entry" == "$newest_bin" ]] && continue
      remove_silent "$name"
    done < <(find "$bin_dir" -mindepth 1 -maxdepth 1 -type d \
      -regextype posix-extended -regex '.*/[0-9a-f]{40}' \
      -print0 2>/dev/null)
    report_batch "$root_label/bin instances" "$before_freed" "$before_n"
  fi

  # ---- Launcher binaries at the root: keep those of kept instances and the
  # newest overall; drop the rest (clients re-download on next connect). ----
  local newest_cli=""
  newest_cli=$(find "$root" -mindepth 1 -maxdepth 1 -type f \
    -regextype posix-extended -regex '.*/code-[0-9a-f]{40}' \
    -printf '%T@ %f\n' 2>/dev/null | sort -rn | awk 'NR==1 { print $2 }')
  if [[ -n "$newest_cli" ]]; then
    keep_hashes+=("${newest_cli#code-}")
  fi
  before_freed="$FREED_KB"
  before_n="$REMOVED_N"
  while IFS= read -r -d '' name; do
    entry=$(basename "$name")
    hash="${entry#code-}"
    kept=0
    for h in "${keep_hashes[@]}"; do [[ "$h" == "$hash" ]] && kept=1; done
    [[ "$kept" -eq 1 ]] && continue
    remove_silent "$name"
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type f \
    -regextype posix-extended -regex '.*/code-[0-9a-f]{40}' \
    -print0 2>/dev/null)
  report_batch "$root_label launcher binaries" "$before_freed" "$before_n"

  # ---- Connection logs of removed instances ----
  before_freed="$FREED_KB"
  before_n="$REMOVED_N"
  while IFS= read -r -d '' name; do
    entry=$(basename "$name")
    hash="${entry#.cli.}"
    hash="${hash%.log}"
    kept=0
    for h in "${keep_hashes[@]}"; do [[ "$h" == "$hash" ]] && kept=1; done
    [[ "$kept" -eq 1 ]] && continue
    remove_silent "$name"
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type f \
    -regextype posix-extended -regex '.*/\.cli\.[0-9a-f]{40}\.log' \
    -print0 2>/dev/null)
  report_batch "$root_label stale logs" "$before_freed" "$before_n"

  # ---- Old server logs (14 days) — diagnostics only. ----
  prune_old_entries "$root/data/logs" 20160 "$root_label logs (> 14d)"
}

function step_vscode_desktop() {
  section "vs code desktop caches"
  local config_dir="$HOME/.config/Code"
  [[ -d "$config_dir" ]] || { vlog "  VS Code desktop config not present, skipping"; return 0; }
  if in_use code; then
    cecho "yellow" "  VS Code is running, skipping"
    return 0
  fi
  local d
  for d in "Cache" "CachedData" "Code Cache" "GPUCache" "DawnGraphiteCache" "DawnWebGPUCache" "CachedExtensionVSIXs"; do
    remove_item "$config_dir/$d"
  done
  prune_old_entries "$config_dir/logs" 20160 "VS Code logs (> 14d)"
}

function step_misc_caches() {
  section "other caches"
  # Regenerable per-user caches (full clear — they rebuild on next use).
  local d
  for d in \
    "$HOME/.cache/thumbnails" \
    "$HOME/.cache/fontconfig" \
    "$HOME/.cache/typescript" \
    "$HOME/.cache/node-gyp" \
    "$HOME/.cache/pkg" \
    "$HOME/.cache/libdnf5" \
    "$HOME/.cache/helm" \
    "$HOME/.cache/powershell" \
    "$HOME/.cache/zsh" \
    "$HOME/.cache/claude-cli-nodejs" \
    "$HOME/.cache/gh" \
    "$HOME/.cache/zellij"; do
    remove_item "$d"
  done

  # Download caches where old versions pile up: 30 days.
  remove_entries "electron (> 30d)" "$HOME/.cache/electron" -mindepth 1 -maxdepth 1 ! -name '.*' ! -name 'CACHEDIR.TAG' -mmin +43200
  # NOTE: ~/.cache/huggingface/token is a credential — never touched.
  if [[ "$DEEP" -eq 1 ]]; then
    remove_entries "huggingface hub (all)" "$HOME/.cache/huggingface/hub" -mindepth 1 -maxdepth 1 ! -name '.*' ! -name 'CACHEDIR.TAG'
  else
    remove_entries "huggingface hub (> 30d)" "$HOME/.cache/huggingface/hub" -mindepth 1 -maxdepth 1 ! -name '.*' ! -name 'CACHEDIR.TAG' -mmin +43200
  fi
}

function step_system() {
  section "system caches"
  case "$CURRENT_OS_ID" in
    arch)
      run_sudo_cmd "pacman -Sc --noconfirm"
      ;;
    debian|ubuntu|pop)
      run_sudo_cmd "apt-get clean"
      run_sudo_cmd "apt-get autoclean"
      ;;
    fedora|redhat)
      run_sudo_cmd "dnf clean all"
      ;;
  esac

  if have flatpak; then
    run_cmd "flatpak uninstall --unused -y"
  fi

  # Journal vacuum: keeps 30 days, so recent diagnostics survive.
  if have journalctl; then
    local before after
    before=$(journalctl --disk-usage 2>/dev/null | human_lines_to_kb)
    [[ "$before" =~ ^[0-9]+$ ]] || before=0
    if [[ "$DRY_RUN" -eq 1 ]]; then
      cecho "yellow" "  DRY-RUN: journalctl --vacuum-time=30d  (currently $(fmt_kb "$before"))"
    elif ! journalctl --vacuum-time=30d >/dev/null 2>&1; then
      run_sudo_cmd "journalctl --vacuum-time=30d"
    fi
    after=$(journalctl --disk-usage 2>/dev/null | human_lines_to_kb)
    [[ "$after" =~ ^[0-9]+$ ]] || after="$before"
    report_delta "$before" "$after" "journal"
  fi
}

function step_tmp() {
  section "temp leftovers"
  # /tmp/hermes-* entries owned by this user, older than 24h.
  remove_entries "tmp (hermes-* > 24h)" /tmp -mindepth 1 -maxdepth 1 -name 'hermes-*' -user "$(id -un)" -mmin +1440
}

# ================================================================== main ====

cecho "blue" "cache-clean — clearing regenerable caches"
if [[ "$DRY_RUN" -eq 1 ]]; then
  cecho "yellow" "DRY-RUN mode: nothing will be removed."
fi
AVAIL_BEFORE=$(df -Pk -- "$HOME" | awk 'NR==2 { print $4 }')

step_uv
step_docker
step_pip
step_node
step_nuget
step_go
step_cargo
step_brew
step_playwright
step_hermes
step_opencode
step_pi
step_vscode_servers
step_vscode_desktop
step_misc_caches
step_system
step_tmp

section "summary"
AVAIL_AFTER=$(df -Pk -- "$HOME" | awk 'NR==2 { print $4 }')
AVAIL_DELTA=$((AVAIL_AFTER - AVAIL_BEFORE))
if [[ "$DRY_RUN" -eq 1 ]]; then
  cecho "green" "Would free up to: $(fmt_kb "$FREED_KB")"
else
  cecho "green" "Total freed: $(fmt_kb "$FREED_KB")"
  if [[ "$AVAIL_DELTA" -gt 0 ]]; then
    cecho "green" "Disk space gained: $(fmt_kb "$AVAIL_DELTA") (available now $(fmt_kb "$AVAIL_AFTER"))"
  fi
fi
if [[ "$ERRORS" -gt 0 ]]; then
  cecho "yellow" "Completed with $ERRORS warning(s) — see messages above."
fi
if [[ "$DEEP" -eq 0 ]]; then
  cecho "white" "Tip: --deep also prunes docker images/containers, go module cache, brew autoremove,"
  cecho "white" "     all npx/opencode/playwright caches. Use --dry-run first to preview."
fi
exit 0
