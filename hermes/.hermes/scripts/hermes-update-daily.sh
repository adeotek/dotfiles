#!/usr/bin/env bash
# Daily Hermes Agent update — fired by the hermes-update systemd user timer at
# 08:00 local. Runs as its own systemd unit (OUTSIDE the gateway cgroup) so the
# updater can safely drain and restart the gateway fleet without killing itself.
set -uo pipefail

HERMES_BIN="$HOME/.local/bin/hermes"
INSTALL_DIR="$HOME/.hermes/hermes-agent"
NOTIFY_SCRIPT="$HOME/.hermes/scripts/hermes-update-notify.sh"
RUN_LOG="$(mktemp)"

notify() { bash "$NOTIFY_SCRIPT" "$1" >>"$RUN_LOG" 2>&1 || true; }

PRE="$(git -C "$INSTALL_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"

if "$HERMES_BIN" update --yes >>"$RUN_LOG" 2>&1; then
    POST="$(git -C "$INSTALL_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    if [[ "$PRE" != "$POST" ]]; then
        notify "✅ Hermes Agent updated ${PRE} → ${POST} (gateway fleet restarted)"
    fi
    # Already up to date → silent success; full log stays in the journal.
else
    rc=$?
    echo "HERMES_UPDATE_DAILY_RESULT=FAILED rc=${rc}" >>"$RUN_LOG"
    notify "⚠️ Hermes Agent daily update FAILED (exit ${rc}). Details: journalctl --user -u hermes-update.service -e"
fi

# The unit reports success regardless of update outcome; detailed failures are
# signaled above (Telegram + journal marker). Unit-level failures (timeout,
# start failure) are handled separately by the OnFailure notifier unit.
rm -f "$RUN_LOG"
exit 0
