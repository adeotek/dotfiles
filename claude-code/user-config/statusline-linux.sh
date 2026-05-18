#!/usr/bin/env bash
# Claude Code statusline — Linux/WSL
# Configure in .claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "bash ~/.claude/statusline.sh"
#   }
# Output:
#   <path> | <git-branch> | <time>
#   <user@host> | <OS> | <version> | <model> | ctx:<pct>%/<size> | 5h:<pct>% | wk:<pct>% | ent:$<spent>/$<limit|∞> (Enterprise) | ext:$<used>/$<limit> (non-Enterprise)

WHITE=$'\033[37m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'
DIM=$'\033[2m'

USAGE_CACHE="$HOME/.claude/statusline-usage-cache.json"
USAGE_CACHE_TTL=120
USAGE_CACHE_ERROR_TTL=3600

get_percent_color() {
    local pct="$1"
    if   [ "$pct" -ge 80 ]; then echo "$RED"
    elif [ "$pct" -ge 50 ]; then echo "$YELLOW"
    else                          echo "$GREEN"
    fi
}

# ── Parse input JSON ──────────────────────────────────────────────────────────

input=$(cat)
eval "$(echo "$input" | jq -r '
  "current_dir=" + (.workspace.current_dir // .cwd // "." | @sh) + "\n" +
  "model_name="  + (.model.display_name // "" | @sh) + "\n" +
  "cc_version="  + (.version // "" | @sh) + "\n" +
  "context_max=" + (.context_window.context_window_size // 200000 | tostring | @sh) + "\n" +
  "context_pct=" + (.context_window.used_percentage // 0 | tostring | @sh)
' 2>/dev/null)"

if [[ "$current_dir" == "$HOME"* ]]; then
    current_dir="~${current_dir#$HOME}"
fi

# ── Git branch ────────────────────────────────────────────────────────────────

git_branch=""
if [ -n "$current_dir" ] && command -v git >/dev/null 2>&1; then
    real_dir="${current_dir/#\~/$HOME}"
    if [[ -d "$real_dir" ]]; then
        git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" symbolic-ref --short HEAD 2>/dev/null \
                  || GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" rev-parse --short HEAD 2>/dev/null)
    fi
fi

# ── Version + context ─────────────────────────────────────────────────────────

if [ -z "$cc_version" ] || [ "$cc_version" = "unknown" ]; then
    cc_version=$(claude --version 2>/dev/null | head -1 | awk '{print $1}')
    cc_version="${cc_version:-unknown}"
fi

context_pct=${context_pct:-0}
context_max=${context_max:-200000}
context_pct_int=${context_pct%%.*}; [ -z "$context_pct_int" ] && context_pct_int=0

format_tokens() {
    local n="$1"
    if   [ "$n" -ge 1000000 ]; then printf "%sM" "$(echo "scale=1; $n / 1000000" | bc 2>/dev/null || echo "$((n / 1000000))")"
    elif [ "$n" -ge 1000 ];    then printf "%sK" "$((n / 1000))"
    else printf "%s" "$n"
    fi
}
context_size_fmt=$(format_tokens "$context_max")

# ── Credentials (single jq call reads both fields) ────────────────────────────

eval "$(jq -r '
  "fetch_token="       + (.claudeAiOauth.accessToken // "" | @sh) + "\n" +
  "subscription_type=" + (.claudeAiOauth.subscriptionType // "" | @sh)
' "${HOME}/.claude/.credentials.json" 2>/dev/null)"
is_enterprise=false
[ "$subscription_type" = "enterprise" ] && is_enterprise=true

# ── Usage cache ───────────────────────────────────────────────────────────────

get_mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }
needs_fetch=true
if [ -f "$USAGE_CACHE" ]; then
    cache_age=$(( $(date +%s) - $(get_mtime "$USAGE_CACHE") ))
    if grep -q '"permission_error"\|"authentication_error"' "$USAGE_CACHE" 2>/dev/null; then
        USAGE_CACHE_TTL=$USAGE_CACHE_ERROR_TTL
    fi
    [ "$cache_age" -le "$USAGE_CACHE_TTL" ] && needs_fetch=false
fi

if [ "$needs_fetch" = "true" ] && [ -n "$fetch_token" ]; then
    # -k: WSL2/Fedora CA bundle may lack the Google Trust Services intermediate
    usage_json=$(curl -sk --max-time 3 \
        -H "Authorization: Bearer $fetch_token" \
        -H "Content-Type: application/json" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
    [ -n "$usage_json" ] && echo "$usage_json" | jq '.' > "$USAGE_CACHE" 2>/dev/null
fi

# ── Usage values ──────────────────────────────────────────────────────────────

usage_5h=0; usage_7d=0; extra_enabled=false; extra_used_cents=0; extra_limit_cents=null
if [ -f "$USAGE_CACHE" ]; then
    eval "$(jq -r '
      "usage_5h="          + (.five_hour.utilization // 0 | tostring | @sh) + "\n" +
      "usage_7d="          + (.seven_day.utilization // 0 | tostring | @sh) + "\n" +
      "extra_enabled="     + (.extra_usage.is_enabled // false | tostring | @sh) + "\n" +
      "extra_used_cents="  + (.extra_usage.used_credits // 0 | tostring | @sh) + "\n" +
      "extra_limit_cents=" + (.extra_usage.monthly_limit | tostring | @sh)
    ' "$USAGE_CACHE" 2>/dev/null)"
fi

usage_5h_int=${usage_5h%%.*}; [ -z "$usage_5h_int" ] && usage_5h_int=0
usage_7d_int=${usage_7d%%.*}; [ -z "$usage_7d_int" ] && usage_7d_int=0

extra_used_dollars=$(( ${extra_used_cents%%.*} / 100 ))
extra_limit_is_unlimited=false
if [ "$extra_limit_cents" = "null" ] || [ -z "$extra_limit_cents" ]; then
    extra_limit_is_unlimited=true
    extra_limit_dollars=0
else
    extra_limit_dollars=$(( ${extra_limit_cents%%.*} / 100 ))
fi

# ── OS label ──────────────────────────────────────────────────────────────────

if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
    os_label="WSL"; os_color="$MAGENTA"
else
    os_label="Linux"; os_color="$GREEN"
fi

# ── Build output ──────────────────────────────────────────────────────────────

sep="${DIM} | ${RESET}"

# Line 1
line1=$(printf "${CYAN}%s${RESET}" "$current_dir")
[[ -n "$git_branch" ]] && line1+="${sep}$(printf "${MAGENTA}%s${RESET}" "$git_branch")"
line1+="${sep}$(printf "${WHITE}%s${RESET}" "$(date +"%H:%M:%S")")"

# Line 2
current_user="${USER:-$(whoami)}"
current_host=$(hostname); current_host=${current_host%%.*}
line2=$(printf "${YELLOW}%s${RESET}${DIM}@${RESET}${WHITE}%s${RESET}" "$current_user" "$current_host")
line2+="${sep}$(printf "${os_color}%s${RESET}" "$os_label")"
line2+="${sep}$(printf "${CYAN}v%s${RESET}" "$cc_version")"
[[ -n "$model_name" ]] && line2+="${sep}$(printf "${MAGENTA}%s${RESET}" "$model_name")"

color_ctx=$(get_percent_color "$context_pct_int")
line2+="${sep}$(printf "${DIM}ctx:${RESET}${color_ctx}%s%%${RESET}${DIM}/${RESET}${CYAN}%s${RESET}" "$context_pct_int" "$context_size_fmt")"

if [ "$usage_7d_int" -gt 0 ] || [ "$usage_5h_int" -gt 0 ]; then
    color_5h=$(get_percent_color "$usage_5h_int")
    line2+="${sep}$(printf "${DIM}5h:${RESET}${color_5h}%s%%${RESET}" "$usage_5h_int")"
    color_7d=$(get_percent_color "$usage_7d_int")
    line2+="${sep}$(printf "${DIM}wk:${RESET}${color_7d}%s%%${RESET}" "$usage_7d_int")"
fi

if [ "$is_enterprise" = "true" ] && [ "$extra_enabled" = "true" ]; then
    if [ "$extra_limit_is_unlimited" = "true" ]; then
        line2+="${sep}$(printf "${DIM}ent:${RESET}${GREEN}\$%s${RESET}${DIM}/∞${RESET}" "$extra_used_dollars")"
    else
        if [ "$extra_limit_dollars" -gt 0 ]; then
            pct=$(( extra_used_dollars * 100 / extra_limit_dollars ))
            color_ent=$(get_percent_color "$pct")
        else
            color_ent="$GREEN"
        fi
        line2+="${sep}$(printf "${DIM}ent:${RESET}${color_ent}\$%s${RESET}${DIM}/${RESET}${CYAN}\$%s${RESET}" "$extra_used_dollars" "$extra_limit_dollars")"
    fi
elif [ "$extra_enabled" = "true" ]; then
    if [ "$extra_limit_dollars" -gt 0 ]; then
        pct=$(( extra_used_dollars * 100 / extra_limit_dollars ))
        color_ext=$(get_percent_color "$pct")
    else
        color_ext="$GREEN"
    fi
    line2+="${sep}$(printf "${DIM}ext:${RESET}${color_ext}\$%s${RESET}${DIM}/${RESET}${CYAN}\$%s${RESET}" "$extra_used_dollars" "$extra_limit_dollars")"
fi

printf "%s\n%s\n" "$line1" "$line2"
