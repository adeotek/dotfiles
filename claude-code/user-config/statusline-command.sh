#!/usr/bin/env bash
# Claude Code statusline — Linux / WSL / Windows
#
# Configure in .claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "bash ~/.claude/statusline-command.sh"
#   }
#
# Output — two lines:
#
#   Line 1:  ~/path/to/dir  [| branch]  | user@host | v1.x.x | Linux|WSL|Windows | HH:MM
#
#   Line 2:  [Plan |]  Model  | ctx:45%/200K  | ln:+0/-0
#              [| 5h:30%(1h30m)]  [| wk:20%(2d3h)]   — rate limits, when present
#              [| ent:$5/∞]  or  [| ent:$5/$50]       — enterprise extra usage
#              [| ext:$5/$50]                           — non-enterprise extra usage
#              [| sc:$0.05]  | tk:12345

# ── ANSI color helpers ───────────────────────────────────────────────────────
RESET=$'\033[0m'
DIM=$'\033[2m'
LDIM=$'\033[90m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
WHITE=$'\033[37m'

# ── Parse JSON input (single read, stored in variable) ───────────────────────
INPUT=$(cat)

# ── Extract all fields in a single jq call ───────────────────────────────────
eval "$(printf '%s' "$INPUT" | jq -r '
  "CWD="               + (.cwd                                     // "" | @sh) + "\n" +
  "MODEL_ID="          + (.model.id                                // "" | @sh) + "\n" +
  "MODEL_NAME="        + (.model.display_name                      // "" | @sh) + "\n" +
  "VERSION="           + (.version                                  // "" | @sh) + "\n" +
  "CTX_TOTAL_IN="      + (.context_window.total_input_tokens  // 0 | tostring) + "\n" +
  "CTX_TOTAL_OUT="     + (.context_window.total_output_tokens // 0 | tostring) + "\n" +
  "CTX_SIZE="          + (.context_window.context_window_size // 0 | tostring) + "\n" +
  "CTX_USED_PCT="      + (.context_window.used_percentage     // 0 | tostring) + "\n" +
  "LINES_ADDED_JSON="  + (.cost.total_lines_added             // 0 | tostring) + "\n" +
  "LINES_REMOVED_JSON="+ (.cost.total_lines_removed           // 0 | tostring) + "\n" +
  "SESSION_COST_JSON=" + (.cost.total_cost_usd               | if . == null then "\"\"" else tostring end) + "\n" +
  "RATE_5H_PCT="       + (.rate_limits.five_hour.used_percentage | if . == null then "\"\"" else tostring end) + "\n" +
  "RATE_5H_RESET="     + (.rate_limits.five_hour.resets_at       | if . == null then "\"\"" else tostring end) + "\n" +
  "RATE_WK_PCT="       + (.rate_limits.seven_day.used_percentage | if . == null then "\"\"" else tostring end) + "\n" +
  "RATE_WK_RESET="     + (.rate_limits.seven_day.resets_at       | if . == null then "\"\"" else tostring end)
' 2>/dev/null)"
if [[ -z "$VERSION" || "$VERSION" == "unknown" ]]; then
    VERSION=$(claude --version 2>/dev/null | head -1 | awk '{print $1}')
    VERSION="${VERSION:-unknown}"
fi

# Plan + OAuth token from credentials file (not present in statusline JSON)
CREDS_FILE="$HOME/.claude/.credentials.json"
RATE_TIER=""
FETCH_TOKEN=""
SUBSCRIPTION_TYPE=""
IS_ENTERPRISE_CREDS=false
if [[ -r "$CREDS_FILE" ]]; then
    eval "$(jq -r '
      "RATE_TIER="          + (.claudeAiOauth.rateLimitTier // "" | @sh) + "\n" +
      "FETCH_TOKEN="        + (.claudeAiOauth.accessToken // "" | @sh) + "\n" +
      "SUBSCRIPTION_TYPE="  + (.claudeAiOauth.subscriptionType // "" | @sh)
    ' "$CREDS_FILE" 2>/dev/null)"
    [[ "$SUBSCRIPTION_TYPE" == "enterprise" ]] && IS_ENTERPRISE_CREDS=true
fi

# ── Extra usage cache (fetched from Anthropic API) ────────────────────────────
USAGE_CACHE="$HOME/.claude/statusline-usage-cache.json"
USAGE_CACHE_TTL=120
USAGE_CACHE_ERROR_TTL=3600

get_mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }

needs_fetch=true
if [[ -f "$USAGE_CACHE" ]]; then
    cache_age=$(( $(date +%s) - $(get_mtime "$USAGE_CACHE") ))
    if grep -q '"permission_error"\|"authentication_error"' "$USAGE_CACHE" 2>/dev/null; then
        USAGE_CACHE_TTL=$USAGE_CACHE_ERROR_TTL
    fi
    [[ "$cache_age" -le "$USAGE_CACHE_TTL" ]] && needs_fetch=false
fi

if [[ "$needs_fetch" == "true" && -n "$FETCH_TOKEN" ]]; then
    usage_json=$(curl -sk --max-time 3 \
        -H "Authorization: Bearer $FETCH_TOKEN" \
        -H "Content-Type: application/json" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
    [[ -n "$usage_json" ]] && printf '%s' "$usage_json" | jq '.' > "$USAGE_CACHE" 2>/dev/null
fi

EXTRA_ENABLED=false
EXTRA_USED_CENTS=0
EXTRA_LIMIT_CENTS=""
if [[ -f "$USAGE_CACHE" ]]; then
    eval "$(jq -r '
      "EXTRA_ENABLED="     + (.extra_usage.is_enabled // false | tostring | @sh) + "\n" +
      "EXTRA_USED_CENTS="  + (.extra_usage.used_credits // 0 | tostring | @sh) + "\n" +
      "EXTRA_LIMIT_CENTS=" + (.extra_usage.monthly_limit // "" | tostring | @sh)
    ' "$USAGE_CACHE" 2>/dev/null)"
fi

EXTRA_USED_DOLLARS=$(( ${EXTRA_USED_CENTS%%.*} / 100 ))
EXTRA_LIMIT_UNLIMITED=false
if [[ -z "$EXTRA_LIMIT_CENTS" || "$EXTRA_LIMIT_CENTS" == "null" ]]; then
    EXTRA_LIMIT_UNLIMITED=true
    EXTRA_LIMIT_DOLLARS=0
else
    EXTRA_LIMIT_DOLLARS=$(( ${EXTRA_LIMIT_CENTS%%.*} / 100 ))
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
CURRENT_USER="${USER:-$(whoami)}"
HOSTNAME_SHORT="${HOSTNAME:-$(hostname -s)}"

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

# Percentage → color (green/yellow/red by threshold); used for ctx and rate limits
pct_color() {
    local pct="${1%.*}"
    if (( pct >= 80 )); then printf '%s' "$RED"
    elif (( pct >= 50 )); then printf '%s' "$YELLOW"
    else printf '%s' "$GREEN"
    fi
}

CTX_PCT_COLOR=$(pct_color "${CTX_USED_PCT:-0}")
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

# Detect plan type: Enterprise if credentials say so, or no rate_limits present.
# Exclude Max/Pro tiers — they can have absent rate-limit data transiently but are never enterprise.
IS_ENTERPRISE=false
IS_NON_ENTERPRISE_PLAN=false
[[ "$RATE_TIER" == *"max"* || "$RATE_TIER" == *"pro"* ]] && IS_NON_ENTERPRISE_PLAN=true
if [[ "$IS_ENTERPRISE_CREDS" == "true" ]] || \
   { [[ -z "$RATE_5H_PCT" && -z "$RATE_WK_PCT" ]] && [[ "$IS_NON_ENTERPRISE_PLAN" == "false" ]]; }; then
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

# Tilde-shorten CWD for display only (raw path already used for git above)
CWD_DISPLAY="$CWD"
[[ "$CWD_DISPLAY" == "$HOME"* ]] && CWD_DISPLAY="~${CWD_DISPLAY#$HOME}"

# ── Build output ──────────────────────────────────────────────────────────────
SEP="${DIM}|${RESET}"
COLON="${DIM}:${RESET}"
SLASH="${DIM}/${RESET}"
AT="${DIM}@${RESET}"
LPAREN="${DIM}(${RESET}"
RPAREN="${DIM})${RESET}"

# ── LINE 1 ────────────────────────────────────────────────────────────────────
LINE1="${CYAN}${CWD_DISPLAY}${RESET}"

if [[ -n "$GIT_BRANCH" ]]; then
    LINE1+=" ${SEP} ${MAGENTA}${GIT_BRANCH}${RESET}"
fi

LINE1+=" ${SEP} ${YELLOW}${CURRENT_USER}${RESET}${AT}${WHITE}${HOSTNAME_SHORT}${RESET}"
LINE1+=" ${SEP} ${CYAN}v${VERSION}${RESET}"
LINE1+=" ${SEP} ${OS_COLOR}${OS_TYPE}${RESET}"
LINE1+=" ${SEP} ${WHITE}${CURRENT_TIME}${RESET}"

# ── LINE 2 ────────────────────────────────────────────────────────────────────
if [[ -n "$PLAN_LABEL" ]]; then
    LINE2="${MAGENTA}${PLAN_LABEL}${RESET}"
    LINE2+=" ${SEP} "
else
    LINE2=""
fi
LINE2+="${MODEL_COLOR}${MODEL_NAME}${RESET}"

# ctx:<pct>/<size>
LINE2+=" ${SEP} ${DIM}ctx${RESET}${COLON}${CTX_PCT_COLOR}${CTX_PCT_DISPLAY}${RESET}${SLASH}${CYAN}${CTX_SIZE_FMT}${RESET}"

# ln:+added/-removed
LINE2+=" ${SEP} ${DIM}ln${RESET}${COLON}${GREEN}+${LINES_ADDED}${RESET}${SLASH}${RED}-${LINES_REMOVED}${RESET}"

if $IS_ENTERPRISE; then
    # 5h / wk rate limits (if present even for enterprise)
    if [[ -n "$RATE_5H_PCT" ]]; then
        FH_COLOR=$(pct_color "$RATE_5H_PCT")
        FH_PCT=$(fmt_pct "$RATE_5H_PCT")
        FH_RESET_STR=""
        [[ -n "$RATE_5H_RESET" ]] && FH_RESET_STR="${LPAREN}${LDIM}$(fmt_reset_time "$RATE_5H_RESET")${RESET}${RPAREN}"
        LINE2+=" ${SEP} ${DIM}5h${RESET}${COLON}${FH_COLOR}${FH_PCT}${RESET}${FH_RESET_STR}"
    fi
    if [[ -n "$RATE_WK_PCT" ]]; then
        WK_COLOR=$(pct_color "$RATE_WK_PCT")
        WK_PCT=$(fmt_pct "$RATE_WK_PCT")
        WK_RESET_STR=""
        [[ -n "$RATE_WK_RESET" ]] && WK_RESET_STR="${LPAREN}${LDIM}$(fmt_reset_time "$RATE_WK_RESET")${RESET}${RPAREN}"
        LINE2+=" ${SEP} ${DIM}wk${RESET}${COLON}${WK_COLOR}${WK_PCT}${RESET}${WK_RESET_STR}"
    fi
    # ent:$used/$limit (or ent:$used/∞)
    if [[ "$EXTRA_ENABLED" == "true" ]]; then
        if [[ "$EXTRA_LIMIT_UNLIMITED" == "true" ]]; then
            LINE2+=" ${SEP} ${DIM}ent${RESET}${COLON}${GREEN}\$${EXTRA_USED_DOLLARS}${RESET}${DIM}/∞${RESET}"
        else
            if [[ "$EXTRA_LIMIT_DOLLARS" -gt 0 ]]; then
                ent_pct=$(( EXTRA_USED_DOLLARS * 100 / EXTRA_LIMIT_DOLLARS ))
                ENT_COLOR=$(pct_color "$ent_pct")
            else
                ENT_COLOR="$GREEN"
            fi
            LINE2+=" ${SEP} ${DIM}ent${RESET}${COLON}${ENT_COLOR}\$${EXTRA_USED_DOLLARS}${RESET}${SLASH}${CYAN}\$${EXTRA_LIMIT_DOLLARS}${RESET}"
        fi
    fi
else
    # 5h:<pct>(<reset>)
    if [[ -n "$RATE_5H_PCT" ]]; then
        FH_COLOR=$(pct_color "$RATE_5H_PCT")
        FH_PCT=$(fmt_pct "$RATE_5H_PCT")
        FH_RESET_STR=""
        [[ -n "$RATE_5H_RESET" ]] && FH_RESET_STR="${LPAREN}${LDIM}$(fmt_reset_time "$RATE_5H_RESET")${RESET}${RPAREN}"
        LINE2+=" ${SEP} ${DIM}5h${RESET}${COLON}${FH_COLOR}${FH_PCT}${RESET}${FH_RESET_STR}"
    fi

    # wk:<pct>(<reset>)
    if [[ -n "$RATE_WK_PCT" ]]; then
        WK_COLOR=$(pct_color "$RATE_WK_PCT")
        WK_PCT=$(fmt_pct "$RATE_WK_PCT")
        WK_RESET_STR=""
        [[ -n "$RATE_WK_RESET" ]] && WK_RESET_STR="${LPAREN}${LDIM}$(fmt_reset_time "$RATE_WK_RESET")${RESET}${RPAREN}"
        LINE2+=" ${SEP} ${DIM}wk${RESET}${COLON}${WK_COLOR}${WK_PCT}${RESET}${WK_RESET_STR}"
    fi

    # ext:$used/$limit (extra usage for non-enterprise)
    if [[ "$EXTRA_ENABLED" == "true" ]]; then
        if [[ "$EXTRA_LIMIT_DOLLARS" -gt 0 ]]; then
            ext_pct=$(( EXTRA_USED_DOLLARS * 100 / EXTRA_LIMIT_DOLLARS ))
            EXT_COLOR=$(pct_color "$ext_pct")
        else
            EXT_COLOR="$GREEN"
        fi
        LINE2+=" ${SEP} ${DIM}ext${RESET}${COLON}${EXT_COLOR}\$${EXTRA_USED_DOLLARS}${RESET}${SLASH}${CYAN}\$${EXTRA_LIMIT_DOLLARS}${RESET}"
    fi
fi

# sc:<session-cost>
if [[ -n "$SESSION_COST" ]]; then
    SC_FMT=$(printf '%.2f' "$SESSION_COST")
    LINE2+=" ${SEP} ${DIM}sc${RESET}${COLON}${MAGENTA}\$${SC_FMT}${RESET}"
fi

# tk:<token-count>
LINE2+=" ${SEP} ${DIM}tk${RESET}${COLON}${LDIM}${TOKEN_COUNT}${RESET}"

printf '%s\n%s\n' "$LINE1" "$LINE2"
