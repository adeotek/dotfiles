#!/bin/bash
# Compact single-call statusline for Claude Code
# Output:
#   <path> | <git-branch> | <time>
#   <user@host> | <OS> | <version> | <model> | ctx:<pct>%/<size> | 5h:<pct>% | wk:<pct>% | ext:$<used>/$<limit>

# ANSI color codes
WHITE='\033[37m'
CYAN='\033[36m'
MAGENTA='\033[35m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'
DIM='\033[2m'

LBLSEP=":"
USAGE_CACHE="$HOME/.claude/usage-cache.json"
USAGE_CACHE_TTL=60
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

# ── Parse input JSON ─────────────────────────────────────────────────────────

input=$(cat)

if [ "$IS_WINDOWS" = "true" ]; then
  _json() {
    # $1 = JS expression that produces the desired value from variable `d`
    # Returns empty string on any error
    printf '%s' "$input" | node -e "
      let raw='';
      process.stdin.setEncoding('utf8');
      process.stdin.on('data',c=>raw+=c);
      process.stdin.on('end',()=>{
        try{
          const d=JSON.parse(raw);
          const v=($1);
          if(v!=null&&v!=='')process.stdout.write(String(v));
        }catch(e){}
      });
    " 2>/dev/null
  }
  current_dir=$(_json "d.workspace&&d.workspace.current_dir||d.cwd||''")
  model_name=$(_json "d.model&&d.model.display_name||''")
  cc_version=$(_json "d.version||'???'")
  context_max=$(_json "d.context_window&&d.context_window.context_window_size||''")
  context_pct=$(_json "d.context_window&&d.context_window.used_percentage!=null?d.context_window.used_percentage:''")
else
  eval "$(echo "$input" | jq -r '
    "current_dir=" + (.workspace.current_dir // .cwd // "." | @sh) + "\n" +
    "model_name="  + (.model.display_name // "unknown" | @sh) + "\n" +
    "cc_version="  + (.version // "" | @sh) + "\n" +
    "context_max=" + (.context_window.context_window_size // 200000 | tostring) + "\n" +
    "context_pct=" + (.context_window.used_percentage // 0 | tostring)
  ' 2>/dev/null)"
  # --- Shorten home directory ---
  home_prefix="$HOME"
  if [[ "$current_dir" == "$home_prefix"* ]]; then
    current_dir="~${current_dir#$home_prefix}"
  fi
fi

# --- Git branch (from cwd, skip optional locks) ---

git_branch=""
if [ "$IS_WINDOWS" = "true" ]; then
  if [ -n "$current_dir" ]; then
    git_branch=$(git -C "$current_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  fi
else
  if command -v git >/dev/null 2>&1; then
    # Resolve the actual directory (cwd may start with ~)
    real_dir="${current_dir/#\~/$HOME}"
    if [[ -d "$real_dir" ]]; then
      git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" symbolic-ref --short HEAD 2>/dev/null \
                  || GIT_OPTIONAL_LOCKS=0 git -C "$real_dir" rev-parse --short HEAD 2>/dev/null)
    fi
  fi
fi

# --- Format context values ---

context_pct=${context_pct:-0}
context_max=${context_max:-200000}

# Fallback cc_version from CLI if not in JSON
if [ -z "$cc_version" ] || [ "$cc_version" = "unknown" ]; then
    cc_version=$(claude --version 2>/dev/null | head -1 | awk '{print $1}')
    cc_version="${cc_version:-unknown}"
fi

# Format context size with K/M notation
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

# --- Refresh usage cache if stale ---

get_mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }

cache_age=999999
[ -f "$USAGE_CACHE" ] && cache_age=$(( $(date +%s) - $(get_mtime "$USAGE_CACHE") ))

if [ "$cache_age" -gt "$USAGE_CACHE_TTL" ]; then
    cred_json=$(cat "${HOME}/.claude/.credentials.json" 2>/dev/null)
    token=$(echo "$cred_json" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('claudeAiOauth', {}).get('accessToken', ''))
" 2>/dev/null)

    if [ -n "$token" ]; then
        usage_json=$(curl -s --max-time 3 \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" \
            -H "anthropic-beta: oauth-2025-04-20" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

        if [ -n "$usage_json" ] && echo "$usage_json" | jq -e '.five_hour' >/dev/null 2>&1; then
            echo "$usage_json" | jq '.' > "$USAGE_CACHE" 2>/dev/null
        fi
    fi
fi

# --- Read usage values ---

usage_5h=0
usage_7d=0
extra_enabled=false
extra_used_cents=0
extra_limit_cents=0

if [ -f "$USAGE_CACHE" ]; then
    eval "$(jq -r '
        "usage_5h="           + (.five_hour.utilization // 0 | tostring) + "\n" +
        "usage_7d="           + (.seven_day.utilization // 0 | tostring) + "\n" +
        "extra_enabled="      + (.extra_usage.is_enabled // false | tostring) + "\n" +
        "extra_used_cents="   + (.extra_usage.used_credits // 0 | tostring) + "\n" +
        "extra_limit_cents="  + (.extra_usage.monthly_limit // 0 | tostring)
    ' "$USAGE_CACHE" 2>/dev/null)"
fi

usage_5h_int=${usage_5h%%.*}
usage_7d_int=${usage_7d%%.*}
[ -z "$usage_5h_int" ]  && usage_5h_int=0
[ -z "$usage_7d_int" ]  && usage_7d_int=0

extra_used_dollars=$(( ${extra_used_cents%%.*} / 100 ))
extra_limit_dollars=$(( ${extra_limit_cents%%.*} / 100 ))

# --- Build output lines ---

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
current_user="${USERNAME:-$(whoami)}"
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
# -- Extra usage (if enabled) --
if [ "$extra_enabled" = "true" ]; then
    out_line_2+="${sep}"
    if [ "$extra_limit_dollars" -eq 0 ]; then
        pct_extra="${GREEN}"
    elif [ "$extra_used_dollars" -eq "$extra_limit_dollars" ]; then
        pct_extra="${RED}"
    else
        pct_extra="${YELLOW}"
    fi
    out_line_2+=$(printf "${DIM}ext${LBLSEP}${RESET}${pct_extra}\$%s${RESET}${DIM}/${RESET}${CYAN}\$%s${RESET}" "$extra_used_dollars" "$extra_limit_dollars")
fi

printf "%s\n%s\n" "$out_line_1" "$out_line_2"
