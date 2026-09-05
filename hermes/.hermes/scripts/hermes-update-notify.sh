#!/usr/bin/env bash
# Send an update-status notification to the Telegram home channel.
# Primary: `hermes send` (works without a running gateway for bot-token platforms).
# Fallback: raw Telegram Bot API via curl using TELEGRAM_BOT_TOKEN from ~/.hermes/.env.
# Best-effort: exit 0 even if both paths fail (journald always has the record).
set -uo pipefail

MSG="${1:?usage: hermes-update-notify.sh 'message text'}"
HERMES_BIN="$HOME/.local/bin/hermes"
# Telegram chat ID of the home channel / DM (config, not a secret).
CHAT_ID="${TELEGRAM_CHAT_ID:-8383493577}"

if "$HERMES_BIN" send -q -t telegram "$MSG"; then
    exit 0
fi

TOKEN="$(grep -m1 '^TELEGRAM_BOT_TOKEN=' "$HOME/.hermes/.env" 2>/dev/null | cut -d= -f2- | tr -d "\"' ")"

if [[ -n "$TOKEN" ]] && command -v curl >/dev/null 2>&1; then
    curl -fsS --max-time 20 "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${MSG}" >/dev/null 2>&1
fi

exit 0
