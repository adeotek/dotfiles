#!/usr/bin/env bash
# Claude Code statusline script

# ── ANSI color helpers ───────────────────────────────────────────────────────
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'          # grey / dimmed
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
WHITE=$'\033[37m'

# ── Parse JSON input (single read, stored in variable) ───────────────────────
INPUT=$(cat)

# Helper: extract a field via jq (used only for non-trivial extractions)
_j() { printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null; }

# ── Extract all needed fields up-front ───────────────────────────────────────
CWD=$(_j '.cwd')
MODEL_ID=$(_j '.model.id')
MODEL_NAME=$(_j '.model.display_name')
VERSION=$(_j '.version')

CTX_TOTAL_IN=$(_j '.context_window.total_input_tokens')
CTX_TOTAL_OUT=$(_j '.context_window.total_output_tokens')
CTX_SIZE=$(_j '.context_window.context_window_size')
CTX_USED_PCT=$(_j '.context_window.used_percentage')

LINES_ADDED_JSON=$(_j '.cost.total_lines_added')
LINES_REMOVED_JSON=$(_j '.cost.total_lines_removed')
SESSION_COST_JSON=$(_j '.cost.total_cost_usd')

RATE_5H_PCT=$(_j '.rate_limits.five_hour.used_percentage')
RATE_5H_RESET=$(_j '.rate_limits.five_hour.resets_at')
RATE_WK_PCT=$(_j '.rate_limits.seven_day.used_percentage')
RATE_WK_RESET=$(_j '.rate_limits.seven_day.resets_at')

# Plan from credentials file (not present in statusline JSON)
CREDS_FILE="$HOME/.claude/.credentials.json"
RATE_TIER=""
if [[ -r "$CREDS_FILE" ]]; then
    RATE_TIER=$(jq -r '.claudeAiOauth.rateLimitTier // empty' "$CREDS_FILE" 2>/dev/null)
fi

# ── Derived values ────────────────────────────────────────────────────────────

# Current time
CURRENT_TIME=$(date +%H:%M)

# OS type detection
OS_TYPE="Linux"
OS_COLOR="$GREEN"
if grep -qi microsoft /proc/version 2>/dev/null; then
    OS_TYPE="WSL"
    OS_COLOR="$MAGENTA"
elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
    OS_TYPE="Windows"
    OS_COLOR="$CYAN"
fi

# Current user and hostname
CURRENT_USER=$(id -un)
HOSTNAME_SHORT=$(hostname -s)

# Git branch (fast: no subprocess if not in a git repo)
GIT_BRANCH=""
if git_root=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null); then
    GIT_BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null \
                 || GIT_OPTIONAL_LOCKS=0 git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
fi

# Lines added/removed come directly from the JSON payload (no git subprocess needed)
LINES_ADDED=${LINES_ADDED_JSON:-0}
LINES_REMOVED=${LINES_REMOVED_JSON:-0}

# Model color
MODEL_COLOR="$CYAN"  # default (Haiku / unknown)
model_id_lower="${MODEL_ID,,}"
if [[ "$model_id_lower" == *"opus"* ]]; then
    MODEL_COLOR="$YELLOW"
elif [[ "$model_id_lower" == *"sonnet"* ]]; then
    MODEL_COLOR="$GREEN"
fi

# Context percentage color
ctx_color_for_pct() {
    local pct="${1%.*}"   # truncate to integer
    if (( pct >= 80 )); then printf '%s' "$RED"
    elif (( pct >= 50 )); then printf '%s' "$YELLOW"
    else printf '%s' "$GREEN"
    fi
}

CTX_PCT_COLOR=$(ctx_color_for_pct "${CTX_USED_PCT:-0}")
CTX_PCT_DISPLAY="${CTX_USED_PCT:-0}"
# Round to 1 decimal if jq gave a float, otherwise keep as-is
if [[ "$CTX_PCT_DISPLAY" == *"."* ]]; then
    CTX_PCT_DISPLAY=$(printf '%.1f' "$CTX_PCT_DISPLAY")
fi
CTX_PCT_DISPLAY="${CTX_PCT_DISPLAY}%"

# Context size formatted (e.g. 200K, 1M)
fmt_ctx_size() {
    local n="$1"
    if (( n >= 1000000 )); then
        printf '%dM' $(( n / 1000000 ))
    elif (( n >= 1000 )); then
        printf '%dK' $(( n / 1000 ))
    else
        printf '%d' "$n"
    fi
}
CTX_SIZE_FMT=$(fmt_ctx_size "${CTX_SIZE:-0}")

# Token count
TOKEN_COUNT=$(( ${CTX_TOTAL_IN:-0} + ${CTX_TOTAL_OUT:-0} ))

# Rate limit helpers
pct_color() {
    local pct="${1%.*}"
    if (( pct >= 80 )); then printf '%s' "$RED"
    elif (( pct >= 50 )); then printf '%s' "$YELLOW"
    else printf '%s' "$GREEN"
    fi
}

fmt_pct() {
    local pct="$1"
    if [[ "$pct" == *"."* ]]; then
        printf '%.1f%%' "$pct"
    else
        printf '%s%%' "$pct"
    fi
}

# Time-remaining formatter: takes a unix epoch and returns e.g. "1h23m" or "45m"
fmt_reset_time() {
    local reset_ts="$1"
    local now
    now=$(date +%s)
    local diff=$(( reset_ts - now ))
    if (( diff <= 0 )); then
        printf 'now'
        return
    fi
    local d=$(( diff / 86400 ))
    local h=$(( (diff % 86400) / 3600 ))
    local m=$(( (diff % 3600) / 60 ))
    if (( d > 0 )); then
        printf '%dd%dh%02dm' "$d" "$h" "$m"
    elif (( h > 0 )); then
        printf '%dh%02dm' "$h" "$m"
    else
        printf '%dm' "$m"
    fi
}

# Detect plan type from rate_limits presence / model ID
# Enterprise: no rate_limits object in JSON, or model contains "enterprise"
# We'll treat it as Enterprise if rate_limits fields are all empty
IS_ENTERPRISE=false
if [[ -z "$RATE_5H_PCT" && -z "$RATE_WK_PCT" ]]; then
    IS_ENTERPRISE=true
fi

# Plan label derived from rateLimitTier in credentials
case "$RATE_TIER" in
    *"max_10x"*)  PLAN_LABEL="Max 10x" ;;
    *"max_5x"*)   PLAN_LABEL="Max 5x" ;;
    *"max"*)      PLAN_LABEL="Max" ;;
    *"pro"*)      PLAN_LABEL="Pro" ;;
    *"enterprise"*) PLAN_LABEL="Enterprise" ;;
    *)            PLAN_LABEL="" ;;
esac

# Session cost from .cost.total_cost_usd
SESSION_COST="$SESSION_COST_JSON"

# ── Build output ──────────────────────────────────────────────────────────────
SEP="${DIM}|${RESET}"
COLON="${DIM}:${RESET}"
SLASH="${DIM}/${RESET}"
AT="${DIM}@${RESET}"
LPAREN="${DIM}(${RESET}"
RPAREN="${DIM})${RESET}"

# ── LINE 1 ────────────────────────────────────────────────────────────────────
LINE1="${CYAN}${CWD}${RESET}"

if [[ -n "$GIT_BRANCH" ]]; then
    LINE1+=" ${SEP} ${MAGENTA}${GIT_BRANCH}${RESET}"
fi

LINE1+=" ${SEP} ${WHITE}${CURRENT_TIME}${RESET}"

if [[ -n "$PLAN_LABEL" ]]; then
    LINE1+=" ${SEP} ${MAGENTA}${PLAN_LABEL}${RESET}"
fi

LINE1+=" ${SEP} ${CYAN}${VERSION}${RESET}"
LINE1+=" ${SEP} ${OS_COLOR}${OS_TYPE}${RESET}"

# ── LINE 2 ────────────────────────────────────────────────────────────────────
LINE2="${YELLOW}${CURRENT_USER}${RESET}${AT}${WHITE}${HOSTNAME_SHORT}${RESET}"
LINE2+=" ${SEP} ${MODEL_COLOR}${MODEL_NAME}${RESET}"

# ctx:<pct>/<size>
LINE2+=" ${SEP} ${DIM}ctx${RESET}${COLON}${CTX_PCT_COLOR}${CTX_PCT_DISPLAY}${RESET}${SLASH}${CYAN}${CTX_SIZE_FMT}${RESET}"

# ln:+added/-removed
LINE2+=" ${SEP} ${DIM}ln${RESET}${COLON}${GREEN}+${LINES_ADDED}${RESET}${SLASH}${RED}-${LINES_REMOVED}${RESET}"

# tk:<token-count>
LINE2+=" ${SEP} ${DIM}tk${RESET}${COLON}${WHITE}${TOKEN_COUNT}${RESET}"

if $IS_ENTERPRISE; then
    # ent:<used>/<limit>
    ENT_USED=$(_j '.enterprise.used_credits // empty')
    ENT_LIMIT=$(_j '.enterprise.credits_limit // empty')
    if [[ -n "$ENT_USED" && -n "$ENT_LIMIT" ]]; then
        ent_pct=$(awk "BEGIN{if($ENT_LIMIT>0) printf \"%.1f\", $ENT_USED/$ENT_LIMIT*100; else print 0}")
        ENT_COLOR=$(pct_color "$ent_pct")
        LINE2+=" ${SEP} ${DIM}ent${RESET}${COLON}${ENT_COLOR}\$${ENT_USED}${RESET}${SLASH}${CYAN}\$${ENT_LIMIT}${RESET}"
    fi
else
    # 5h:<pct>(<reset>)
    if [[ -n "$RATE_5H_PCT" ]]; then
        FH_COLOR=$(pct_color "$RATE_5H_PCT")
        FH_PCT=$(fmt_pct "$RATE_5H_PCT")
        FH_RESET_STR=""
        if [[ -n "$RATE_5H_RESET" ]]; then
            FH_RESET_STR="${LPAREN}${DIM}$(fmt_reset_time "$RATE_5H_RESET")${RESET}${RPAREN}"
        fi
        LINE2+=" ${SEP} ${DIM}5h${RESET}${COLON}${FH_COLOR}${FH_PCT}${RESET}${FH_RESET_STR}"
    fi

    # wk:<pct>(<reset>)
    if [[ -n "$RATE_WK_PCT" ]]; then
        WK_COLOR=$(pct_color "$RATE_WK_PCT")
        WK_PCT=$(fmt_pct "$RATE_WK_PCT")
        WK_RESET_STR=""
        if [[ -n "$RATE_WK_RESET" ]]; then
            WK_RESET_STR="${LPAREN}${DIM}$(fmt_reset_time "$RATE_WK_RESET")${RESET}${RPAREN}"
        fi
        LINE2+=" ${SEP} ${DIM}wk${RESET}${COLON}${WK_COLOR}${WK_PCT}${RESET}${WK_RESET_STR}"
    fi

fi

# sc:<session-cost>
if [[ -n "$SESSION_COST" ]]; then
    SC_FMT=$(printf '%.2f' "$SESSION_COST")
    LINE2+=" ${SEP} ${DIM}sc${RESET}${COLON}${MAGENTA}\$${SC_FMT}${RESET}"
fi

printf '%s\n%s\n' "$LINE1" "$LINE2"
