#!/bin/bash
# Compact single-call statusline for Claude Code
# Output:
#   <path> | <git-branch> | <time>
#   <user@host> | <OS> | <version> | <model> | ctx:<pct>%/<size> | 5h:<pct>% | wk:<pct>% | ent:$<spent>/$<limit|∞> (Enterprise) | ext:$<used>/$<limit> (non-Enterprise)

# ANSI color codes
WHITE=$'\033[37m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'
DIM=$'\033[2m'

LBLSEP=":"
USAGE_CACHE="$HOME/.claude/usage-cache.json"
USAGE_CACHE_TTL=60
USAGE_CACHE_ERROR_TTL=3600  # back off 1 hour on permission/auth errors
IS_WINDOWS=$(if uname | grep -qi 'mingw\|cygwin\|msys'; then echo true; else echo false; fi)

get_percent_color() {
    local pct="$1"
    if [ "$pct" -ge 80 ]; then
        echo "$RED"
    elif [ "$pct" -ge 50 ]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

# ── Parse input + read all JSON sources ──────────────────────────────────────

input=$(cat)

if [ "$IS_WINDOWS" = "true" ]; then
  # Single pwsh call: parse stdin JSON, read credentials, check/read cache.
  # Outputs shell variable assignments for every field needed by this script,
  # including cache freshness so we know whether to curl the usage API.
  eval "$(printf '%s' "$input" | pwsh -NoProfile -NonInteractive -Command '
    function js([string]$s) { $s | ConvertTo-Json -Compress }

    $d = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction SilentlyContinue

    $current_dir = [string]($d.workspace.current_dir ?? $d.cwd ?? "")
    $model_name  = [string]($d.model.display_name ?? "")
    $cc_version  = [string]($d.version ?? "")
    $context_max = if ($null -ne $d.context_window.context_window_size) { [string]$d.context_window.context_window_size } else { "" }
    $context_pct = if ($null -ne $d.context_window.used_percentage) { [string]$d.context_window.used_percentage } else { "" }

    $creds = $null
    $creds_path = "$env:USERPROFILE\.claude\.credentials.json"
    if (Test-Path $creds_path) {
      try { $creds = Get-Content $creds_path -Raw | ConvertFrom-Json } catch {}
    }
    $token             = [string]($creds.claudeAiOauth.accessToken ?? "")
    $subscription_type = [string]($creds.claudeAiOauth.subscriptionType ?? "")

    $cache_path = "$env:USERPROFILE\.claude\usage-cache.json"
    $cache_needs_refresh = "true"
    $usage_5h = "0"; $usage_7d = "0"
    $extra_enabled = "false"; $extra_used_cents = "0"; $extra_limit_cents = "null"

    if (Test-Path $cache_path) {
      $cache_raw = Get-Content $cache_path -Raw
      $ttl = if ($cache_raw -match "permission_error|authentication_error") { 3600 } else { 60 }
      if (((Get-Date) - (Get-Item $cache_path).LastWriteTime).TotalSeconds -le $ttl) {
        $cache_needs_refresh = "false"
        try {
          $u = $cache_raw | ConvertFrom-Json
          $eu = $u.extra_usage
          $usage_5h          = [string]($u.five_hour.utilization ?? 0)
          $usage_7d          = [string]($u.seven_day.utilization ?? 0)
          $extra_enabled     = if ($eu.is_enabled -eq $true) { "true" } else { "false" }
          $extra_used_cents  = [string]($eu.used_credits ?? 0)
          $extra_limit_cents = if ($null -ne $eu.monthly_limit) { [string]$eu.monthly_limit } else { "null" }
        } catch {}
      }
    }

    @(
      "current_dir="         + (js $current_dir),
      "model_name="          + (js $model_name),
      "cc_version="          + (js $cc_version),
      "context_max="         + (js $context_max),
      "context_pct="         + (js $context_pct),
      "token="               + (js $token),
      "subscription_type="   + (js $subscription_type),
      "cache_needs_refresh=" + (js $cache_needs_refresh),
      "usage_5h="            + (js $usage_5h),
      "usage_7d="            + (js $usage_7d),
      "extra_enabled="       + (js $extra_enabled),
      "extra_used_cents="    + (js $extra_used_cents),
      "extra_limit_cents="   + (js $extra_limit_cents)
    ) -join "`n"
  ' 2>/dev/null)"

else
  eval "$(echo "$input" | jq -r '
    "current_dir=" + (.workspace.current_dir // .cwd // "." | @sh) + "\n" +
    "model_name="  + (.model.display_name // "unknown" | @sh) + "\n" +
    "cc_version="  + (.version // "" | @sh) + "\n" +
    "context_max=" + (.context_window.context_window_size // 200000 | tostring | @sh) + "\n" +
    "context_pct=" + (.context_window.used_percentage // 0 | tostring | @sh)
  ' 2>/dev/null)"
  home_prefix="$HOME"
  if [[ "$current_dir" == "$home_prefix"* ]]; then
    current_dir="~${current_dir#$home_prefix}"
  fi
fi

# ── Git branch ────────────────────────────────────────────────────────────────

git_branch=""
if [ -n "$current_dir" ] && command -v git >/dev/null 2>&1; then
  if [ "$IS_WINDOWS" = "true" ]; then
    git_branch=$(git -C "$current_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  else
    real_dir="${current_dir/#\~/$HOME}"
    if [[ -d "$real_dir" ]]; then
      git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" symbolic-ref --short HEAD 2>/dev/null \
                  || GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" rev-parse --short HEAD 2>/dev/null)
    fi
  fi
fi

# ── Format context values ─────────────────────────────────────────────────────

context_pct=${context_pct:-0}
context_max=${context_max:-200000}

if [ -z "$cc_version" ] || [ "$cc_version" = "unknown" ]; then
    cc_version=$(claude --version 2>/dev/null | head -1 | awk '{print $1}')
    cc_version="${cc_version:-unknown}"
fi

format_tokens() {
    local n="$1"
    if   [ "$n" -ge 1000000 ]; then printf "%sM" "$(echo "scale=1; $n / 1000000" | bc 2>/dev/null || echo "$((n / 1000000))")"
    elif [ "$n" -ge 1000 ];    then printf "%sK" "$((n / 1000))"
    else printf "%s" "$n"
    fi
}

context_size_fmt=$(format_tokens "$context_max")
context_pct_int=${context_pct%%.*}
[ -z "$context_pct_int" ] && context_pct_int=0

# ── Refresh usage cache if stale ─────────────────────────────────────────────

if [ "$IS_WINDOWS" = "true" ]; then
  # cache_needs_refresh was determined inside the pwsh block above
  needs_fetch="${cache_needs_refresh:-true}"
else
  get_mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }
  needs_fetch=true
  if [ -f "$USAGE_CACHE" ]; then
    cache_age=$(( $(date +%s) - $(get_mtime "$USAGE_CACHE") ))
    if grep -q '"permission_error"\|"authentication_error"' "$USAGE_CACHE" 2>/dev/null; then
      USAGE_CACHE_TTL=$USAGE_CACHE_ERROR_TTL
    fi
    [ "$cache_age" -le "$USAGE_CACHE_TTL" ] && needs_fetch=false
  fi
fi

if [ "$needs_fetch" = "true" ]; then
  if [ "$IS_WINDOWS" = "true" ]; then
    fetch_token="$token"
  else
    fetch_token=$(jq -r '.claudeAiOauth.accessToken // empty' "${HOME}/.claude/.credentials.json" 2>/dev/null)
  fi

  if [ -n "$fetch_token" ]; then
    # -k: WSL2/Fedora CA bundle may lack the Google Trust Services intermediate
    usage_json=$(curl -sk --max-time 3 \
        -H "Authorization: Bearer $fetch_token" \
        -H "Content-Type: application/json" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    if [ -n "$usage_json" ]; then
      if [ "$IS_WINDOWS" = "true" ]; then
        printf '%s' "$usage_json" > "$USAGE_CACHE"
      else
        # jq '.' validates JSON and pretty-prints; writes any valid JSON response
        echo "$usage_json" | jq '.' > "$USAGE_CACHE" 2>/dev/null
      fi
    fi
  fi
fi

# ── Read usage values ─────────────────────────────────────────────────────────

# Defaults (override by pwsh/jq blocks below if cache is available)
usage_5h=${usage_5h:-0}
usage_7d=${usage_7d:-0}
extra_enabled=${extra_enabled:-false}
extra_used_cents=${extra_used_cents:-0}
extra_limit_cents=${extra_limit_cents:-0}

if [ "$IS_WINDOWS" = "true" ]; then
  # If cache was just refreshed, re-read it; otherwise values are already set
  # from the initial pwsh call above.
  if [ "$needs_fetch" = "true" ] && [ -f "$USAGE_CACHE" ]; then
    eval "$(pwsh -NoProfile -NonInteractive -Command '
      try {
        $u  = Get-Content "$env:USERPROFILE\.claude\usage-cache.json" -Raw | ConvertFrom-Json
        $eu = $u.extra_usage
        $ee = if ($eu.is_enabled -eq $true) { "true" } else { "false" }
        $el = if ($null -ne $eu.monthly_limit) { [string]$eu.monthly_limit } else { "null" }
        @(
          "usage_5h="          + ([string]($u.five_hour.utilization ?? 0) | ConvertTo-Json -Compress),
          "usage_7d="          + ([string]($u.seven_day.utilization ?? 0) | ConvertTo-Json -Compress),
          "extra_enabled="     + ($ee | ConvertTo-Json -Compress),
          "extra_used_cents="  + ([string]($eu.used_credits ?? 0) | ConvertTo-Json -Compress),
          "extra_limit_cents=" + ($el | ConvertTo-Json -Compress)
        ) -join "`n"
      } catch {}
    ' 2>/dev/null)"
  fi
elif [ -f "$USAGE_CACHE" ]; then
  eval "$(jq -r '
    "usage_5h="           + (.five_hour.utilization // 0 | tostring | @sh) + "\n" +
    "usage_7d="           + (.seven_day.utilization // 0 | tostring | @sh) + "\n" +
    "extra_enabled="      + (.extra_usage.is_enabled // false | tostring | @sh) + "\n" +
    "extra_used_cents="   + (.extra_usage.used_credits // 0 | tostring | @sh) + "\n" +
    "extra_limit_cents="  + (.extra_usage.monthly_limit | tostring | @sh)
  ' "$USAGE_CACHE" 2>/dev/null)"
fi

# ── Subscription type (Windows: already set by initial pwsh call) ─────────────

if [ "$IS_WINDOWS" != "true" ]; then
  subscription_type=$(jq -r '.claudeAiOauth.subscriptionType // empty' "${HOME}/.claude/.credentials.json" 2>/dev/null)
fi
is_enterprise=false
[ "$subscription_type" = "enterprise" ] && is_enterprise=true

# ── Integer truncation for percent comparisons ────────────────────────────────

usage_5h_int=${usage_5h%%.*}
usage_7d_int=${usage_7d%%.*}
[ -z "$usage_5h_int" ] && usage_5h_int=0
[ -z "$usage_7d_int" ] && usage_7d_int=0

# ── Dollar conversions ────────────────────────────────────────────────────────

extra_used_dollars=$(( ${extra_used_cents%%.*} / 100 ))
# null monthly_limit means unlimited Enterprise spend (no cap set by org admin)
extra_limit_is_unlimited=false
if [ "$extra_limit_cents" = "null" ] || [ -z "$extra_limit_cents" ]; then
    extra_limit_is_unlimited=true
    extra_limit_dollars=0
else
    extra_limit_dollars=$(( ${extra_limit_cents%%.*} / 100 ))
fi

# ── Build output lines ────────────────────────────────────────────────────────

sep="${DIM} | ${RESET}"
out_line_1=""
out_line_2=""

# -- Path --
out_line_1+=$(printf "${CYAN}%s${RESET}" "$current_dir")
# -- Git branch --
if [[ -n "$git_branch" ]]; then
  out_line_1+="${sep}"
  out_line_1+=$(printf "${MAGENTA}%s${RESET}" "$git_branch")
fi
# -- Time --
out_line_1+="${sep}"
current_time=$(date +"%H:%M:%S")
out_line_1+=$(printf "${WHITE}%s${RESET}" "$current_time")

# -- User@Host --
current_user="${USER:-${USERNAME:-$(whoami)}}"
current_host=$(hostname || echo "${HOSTNAME}"); current_host=${current_host%%.*}
out_line_2+=$(printf "${YELLOW}%s${RESET}${DIM}@${RESET}${WHITE}%s${RESET}" "${current_user}" "${current_host}")
# -- OS --
out_line_2+="${sep}"
if [ "$IS_WINDOWS" = "true" ]; then
    out_line_2+=$(printf "${BLUE}%s${RESET}" "Windows")
elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    out_line_2+=$(printf "${MAGENTA}%s${RESET}" "WSL")
else
    out_line_2+=$(printf "${GREEN}%s${RESET}" "Linux")
fi
# -- Version --
out_line_2+="${sep}"
out_line_2+=$(printf "${CYAN}v%s${RESET}" "$cc_version")
# -- Model --
if [[ -n "$model_name" ]]; then
  out_line_2+="${sep}"
  out_line_2+=$(printf "${MAGENTA}%s${RESET}" "$model_name")
fi
# -- Context --
out_line_2+="${sep}"
color_ctx=$(get_percent_color "$context_pct_int")
out_line_2+=$(printf "${DIM}ctx${LBLSEP}${RESET}${color_ctx}%s%%${RESET}${DIM}/${RESET}${CYAN}%s${RESET}" "$context_pct_int" "$context_size_fmt")
if [ "$usage_7d_int" -gt 0 ] || [ "$usage_5h_int" -gt 0 ]; then
  # -- Usage 5h --
  out_line_2+="${sep}"
  color_5h=$(get_percent_color "$usage_5h_int")
  out_line_2+=$(printf "${DIM}5h${LBLSEP}${RESET}${color_5h}%s%%${RESET}" "$usage_5h_int")
  # -- Usage 7d --
  out_line_2+="${sep}"
  color_7d=$(get_percent_color "$usage_7d_int")
  out_line_2+=$(printf "${DIM}wk${LBLSEP}${RESET}${color_7d}%s%%${RESET}" "$usage_7d_int")
fi
# -- Enterprise usage (Enterprise accounts) or Extra usage (non-Enterprise) --
if [ "$is_enterprise" = "true" ] && [ "$extra_enabled" = "true" ]; then
    out_line_2+="${sep}"
    if [ "$extra_limit_is_unlimited" = "true" ]; then
        out_line_2+=$(printf "${DIM}ent${LBLSEP}${RESET}${GREEN}\$%s${RESET}${DIM}/∞${RESET}" "$extra_used_dollars")
    else
        if [ "$extra_limit_dollars" -gt 0 ]; then
            pct_ent_int=$(( extra_used_dollars * 100 / extra_limit_dollars ))
            color_ent=$(get_percent_color "$pct_ent_int")
        else
            color_ent="${GREEN}"
        fi
        out_line_2+=$(printf "${DIM}ent${LBLSEP}${RESET}${color_ent}\$%s${RESET}${DIM}/${RESET}${CYAN}\$%s${RESET}" "$extra_used_dollars" "$extra_limit_dollars")
    fi
elif [ "$extra_enabled" = "true" ]; then
    out_line_2+="${sep}"
    if [ "$extra_limit_dollars" -gt 0 ]; then
        pct_extra_int=$(( extra_used_dollars * 100 / extra_limit_dollars ))
        pct_extra=$(get_percent_color "$pct_extra_int")
    else
        pct_extra="${GREEN}"
    fi
    out_line_2+=$(printf "${DIM}ext${LBLSEP}${RESET}${pct_extra}\$%s${RESET}${DIM}/${RESET}${CYAN}\$%s${RESET}" "$extra_used_dollars" "$extra_limit_dollars")
fi

printf "%s\n%s\n" "$out_line_1" "$out_line_2"
