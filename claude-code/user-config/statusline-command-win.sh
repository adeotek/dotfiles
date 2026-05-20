#!/usr/bin/env bash
# Claude Code statusline — Git Bash / Windows
#
# Configure in .claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "bash ~/.claude/statusline-command-win.sh"
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

ESC=$'\033'
Reset="${ESC}[0m"; Dim="${ESC}[2m"; LightDim="${ESC}[90m"
White="${ESC}[37m"; Cyan="${ESC}[36m"; Magenta="${ESC}[35m"
Blue="${ESC}[34m"; Green="${ESC}[32m"; Yellow="${ESC}[33m"
Red="${ESC}[31m"

sep="${Dim}|${Reset}"; colon="${Dim}:${Reset}"; slash="${Dim}/${Reset}"
at="${Dim}@${Reset}"; lp="${Dim}(${Reset}"; rp="${Dim})${Reset}"

# Read stdin with timeout
raw=$(timeout 1 cat 2>/dev/null)
[[ -z "$raw" || "$raw" == "null" ]] && raw="{}"

jqr() { printf '%s' "$raw" | jq -r "$1 // empty" 2>/dev/null; }
jqn() { printf '%s' "$raw" | jq -r "$1 // 0"     2>/dev/null; }

current_dir=$(jqr '.cwd')
model_id=$(jqr '.model.id')
model_name=$(jqr '.model.display_name')
cc_version=$(jqr '.version')

ctx_in=$(jqn '.context_window.total_input_tokens')
ctx_out=$(jqn '.context_window.total_output_tokens')
ctx_size=$(printf '%s' "$raw" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null)
ctx_pct=$(printf '%s' "$raw"  | jq -r '.context_window.used_percentage // 0'          2>/dev/null)

lines_added=$(jqn '.cost.total_lines_added')
lines_removed=$(jqn '.cost.total_lines_removed')
session_cost=$(jqr '.cost.total_cost_usd')

rate_5h_pct=$(jqr '.rate_limits.five_hour.used_percentage')
rate_5h_reset=$(jqr '.rate_limits.five_hour.resets_at')
rate_wk_pct=$(jqr '.rate_limits.seven_day.used_percentage')
rate_wk_reset=$(jqr '.rate_limits.seven_day.resets_at')

# Normalise path: convert Windows backslashes and drive letter to Git Bash
# Unix style (C:\foo\bar → /c/foo/bar) BEFORE tilde-shortening, so that
# the result matches $HOME which Git Bash always exposes as /c/Users/...
dir_display="${current_dir:-$PWD}"
dir_display="${dir_display//\\//}"
if [[ "$dir_display" =~ ^([A-Za-z]):/ ]]; then
    drive="${BASH_REMATCH[1],,}"
    dir_display="/${drive}${dir_display:2}"
fi
[[ "$dir_display" == "$HOME"* ]] && dir_display="~${dir_display#$HOME}"

# Git branch
git_branch=""
if [[ -n "$current_dir" && -d "$current_dir" ]]; then
    git_branch=$(git -C "$current_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
    [[ -z "$git_branch" ]] && git_branch=$(git -C "$current_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# Version fallback
if [[ -z "$cc_version" || "$cc_version" == "unknown" ]]; then
    cc_version=$(claude --version 2>/dev/null | head -1 | sed 's/ .*//')
    [[ -z "$cc_version" ]] && cc_version="?"
fi

# Credentials
creds_path="$HOME/.claude/.credentials.json"
fetch_token=""; rate_tier=""; subscription_type=""
if [[ -f "$creds_path" ]]; then
    fetch_token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_path" 2>/dev/null)
    rate_tier=$(jq -r '.claudeAiOauth.rateLimitTier // empty' "$creds_path" 2>/dev/null)
    subscription_type=$(jq -r '.claudeAiOauth.subscriptionType // empty' "$creds_path" 2>/dev/null)
fi
[[ "$subscription_type" == "enterprise" ]] && is_enterprise_creds=1 || is_enterprise_creds=0

# Extra usage cache
cache_path="$HOME/.claude/statusline-usage-cache.json"
cache_ttl=120; cache_error_ttl=3600
extra_enabled="false"; extra_used=0; extra_limit=""
needs_fetch=1

if [[ -f "$cache_path" ]]; then
    cache_content=$(cat "$cache_path" 2>/dev/null)
    if echo "$cache_content" | grep -q "permission_error\|authentication_error"; then
        ttl=$cache_error_ttl
    else
        ttl=$cache_ttl
    fi
    cache_mtime=$(stat -c %Y "$cache_path" 2>/dev/null)
    now_epoch=$(date +%s)
    if [[ $(( now_epoch - cache_mtime )) -le $ttl ]]; then
        needs_fetch=0
        extra_enabled=$(echo "$cache_content" | jq -r '.extra_usage.is_enabled // false'   2>/dev/null)
        extra_used=$(echo "$cache_content"    | jq -r '.extra_usage.used_credits // 0'      2>/dev/null)
        extra_limit=$(echo "$cache_content"   | jq -r '.extra_usage.monthly_limit // empty' 2>/dev/null)
    fi
fi

if [[ $needs_fetch -eq 1 && -n "$fetch_token" ]]; then
    response=$(curl -s --max-time 3 \
        -H "Authorization: Bearer $fetch_token" \
        -H "Content-Type: application/json" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
    if [[ -n "$response" ]]; then
        echo "$response" > "$cache_path"
        extra_enabled=$(echo "$response" | jq -r '.extra_usage.is_enabled // false'   2>/dev/null)
        extra_used=$(echo "$response"    | jq -r '.extra_usage.used_credits // 0'      2>/dev/null)
        extra_limit=$(echo "$response"   | jq -r '.extra_usage.monthly_limit // empty' 2>/dev/null)
    fi
fi

pct_color() {
    local pct=${1%.*}
    (( pct >= 80 )) && { echo "$Red";    return; }
    (( pct >= 50 )) && { echo "$Yellow"; return; }
    echo "$Green"
}

format_tokens() {
    local n=${1%.*}
    (( n >= 1000000 )) && { echo "$((n/1000000))M"; return; }
    (( n >= 1000    )) && { echo "$((n/1000))K";    return; }
    echo "$n"
}

format_reset() {
    local epoch=$1 now diff d h m
    now=$(date +%s); diff=$(( epoch - now ))
    (( diff <= 0 )) && { echo "now"; return; }
    d=$(( diff/86400 )); h=$(( (diff%86400)/3600 )); m=$(( (diff%3600)/60 ))
    (( d > 0 )) && { printf '%dd%dh%02dm' $d $h $m; return; }
    (( h > 0 )) && { printf '%dh%02dm' $h $m;       return; }
    echo "${m}m"
}

# Format an integer cent value as a dollar string: 27→0.27, 2000→20, 2050→20.50
cents_to_dollars() {
    local n=${1%.*}
    local d=$(( n / 100 )) c=$(( n % 100 ))
    (( c == 0 )) && echo "$d" || printf '%d.%02d' $d $c
}

# Derived values
[[ "$rate_tier" =~ max|pro ]] && is_non_enterprise=1 || is_non_enterprise=0
is_enterprise=0
if [[ $is_enterprise_creds -eq 1 ]] || \
   { [[ -z "$rate_5h_pct" && -z "$rate_wk_pct" ]] && [[ $is_non_enterprise -eq 0 ]]; }; then
    is_enterprise=1
fi

case "$rate_tier" in
    *max_10x*)    plan_label="Max 10x"    ;;
    *max_5x*)     plan_label="Max 5x"     ;;
    *max*)        plan_label="Max"        ;;
    *pro*)        plan_label="Pro"        ;;
    *)            plan_label="Enterprise" ;;
esac

model_color="$Cyan"
[[ "$model_id" == *"opus"*   ]] && model_color="$Yellow"
[[ "$model_id" == *"sonnet"* ]] && model_color="$Green"

ctx_pct_int=${ctx_pct%.*}
ctx_size_fmt=$(format_tokens "${ctx_size:-200000}")
token_count=$(( ctx_in + ctx_out ))

ctx_pct_display="$(printf '%.0f' "${ctx_pct:-0}")%"
ctx_color=$(pct_color "${ctx_pct_int:-0}")

# ── Line 1 ─────────────────────────────────────────────────────────────
line1="${Cyan}${dir_display}${Reset}"
[[ -n "$git_branch" ]] && line1+=" ${sep} ${Magenta}${git_branch}${Reset}"
line1+=" ${sep} ${Yellow}${USER:-$USERNAME}${Reset}${at}${White}${COMPUTERNAME:-$(hostname)}${Reset}"
line1+=" ${sep} ${Cyan}v${cc_version}${Reset}"
line1+=" ${sep} ${Blue}Windows${Reset}"
line1+=" ${sep} ${White}$(date '+%H:%M')${Reset}"

# ── Line 2 ─────────────────────────────────────────────────────────────
line2=""
[[ -n "$plan_label" ]] && line2="${Magenta}${plan_label}${Reset} ${sep} "
line2+="${model_color}${model_name}${Reset}"
line2+=" ${sep} ${Dim}ctx${Reset}${colon}${ctx_color}${ctx_pct_display}${Reset}${slash}${Cyan}${ctx_size_fmt}${Reset}"
line2+=" ${sep} ${Dim}ln${Reset}${colon}${Green}+${lines_added}${Reset}${slash}${Red}-${lines_removed}${Reset}"

if [[ -n "$rate_5h_pct" ]]; then
    r_color=$(pct_color "${rate_5h_pct%.*}")
    rate_5h_pct_int=$(printf '%.0f' "$rate_5h_pct")
    reset_str=""; [[ -n "$rate_5h_reset" ]] && reset_str="${lp}${LightDim}$(format_reset "$rate_5h_reset")${Reset}${rp}"
    line2+=" ${sep} ${Dim}5h${Reset}${colon}${r_color}${rate_5h_pct_int}%${Reset}${reset_str}"
fi
if [[ -n "$rate_wk_pct" ]]; then
    r_color=$(pct_color "${rate_wk_pct%.*}")
    rate_wk_pct_int=$(printf '%.0f' "$rate_wk_pct")
    reset_str=""; [[ -n "$rate_wk_reset" ]] && reset_str="${lp}${LightDim}$(format_reset "$rate_wk_reset")${Reset}${rp}"
    line2+=" ${sep} ${Dim}wk${Reset}${colon}${r_color}${rate_wk_pct_int}%${Reset}${reset_str}"
fi

if [[ "$extra_enabled" == "true" ]]; then
    extra_used_int=${extra_used%.*}
    extra_used_fmt=$(cents_to_dollars "$extra_used_int")
    label="ext"; [[ $is_enterprise -eq 1 ]] && label="ent"

    if [[ -z "$extra_limit" ]]; then
        line2+=" ${sep} ${Dim}${label}${Reset}${colon}${Green}\$${extra_used_fmt}${Reset}${Dim}/∞${Reset}"
    else
        extra_limit_int=${extra_limit%.*}
        pct=0; (( extra_limit_int > 0 )) && pct=$(( extra_used_int * 100 / extra_limit_int ))
        e_color=$(pct_color $pct)
        extra_limit_fmt=$(cents_to_dollars "$extra_limit_int")
        line2+=" ${sep} ${Dim}${label}${Reset}${colon}${e_color}\$${extra_used_fmt}${Reset}${slash}${Cyan}\$${extra_limit_fmt}${Reset}"
    fi
fi

if [[ -n "$session_cost" ]]; then
    line2+=" ${sep} ${Dim}sc${Reset}${colon}${Magenta}\$$(printf '%.2f' "$session_cost")${Reset}"
fi
line2+=" ${sep} ${Dim}tk${Reset}${colon}${LightDim}${token_count}${Reset}"

printf '%s\n' "$line1"
printf '%s\n' "$line2"
