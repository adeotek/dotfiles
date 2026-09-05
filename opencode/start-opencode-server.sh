#!/usr/bin/env bash
# Start the OpenCode headless backend bound to all interfaces, with basic auth,
# so the Desktop app on another computer can attach to it over the LAN.
#
# Usage on the remote machine:
#   OPENCODE_SERVER_PASSWORD='<same password>' opencode attach http://<this-host>:4096

set -euo pipefail

# --- Config -------------------------------------------------------------------

# Source a sibling .env file if it exists (keeps secrets out of the shell profile).
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${script_dir}/.env"
if [[ -f "${env_file}" ]]; then
  # shellcheck disable=SC1090
  source "${env_file}"
fi

: "${OPENCODE_HOST:=0.0.0.0}"
: "${OPENCODE_PORT:=4096}"
: "${OPENCODE_USERNAME:=opencode}"

# --- Pre-flight ----------------------------------------------------------------

if [[ -z "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
  echo "ERROR: OPENCODE_SERVER_PASSWORD is not set or empty." >&2
  echo "Refusing to start an unauthenticated internet-facing server." >&2
  echo "" >&2
  echo "Set it in ${env_file}:" >&2
  echo "  OPENCODE_SERVER_PASSWORD='your-secret-here'" >&2
  echo "or export it in your shell profile:" >&2
  echo "  export OPENCODE_SERVER_PASSWORD='your-secret-here'" >&2
  exit 1
fi

command -v opencode >/dev/null 2>&1 || {
  echo "ERROR: 'opencode' not found on PATH." >&2
  exit 1
}

# --- Connection info -----------------------------------------------------------

echo "Starting opencode serve…"
echo "  host:     ${OPENCODE_HOST}"
echo "  port:     ${OPENCODE_PORT}"
echo "  username: ${OPENCODE_USERNAME}"
echo ""
echo "Reachable at (use one of these from the remote Desktop app):"
# Print each non-empty LAN IPv4 address from `hostname -I`.
while IFS= read -r ip; do
  [[ -n "${ip}" ]] && echo "  http://${ip}:${OPENCODE_PORT}"
done < <(printf '%s\n' $(hostname -I))
echo "  http://localhost:${OPENCODE_PORT}"
echo ""
echo "On the remote machine run:"
echo "  OPENCODE_SERVER_PASSWORD='<your password>' \\"
echo "  opencode attach http://<this-host>:${OPENCODE_PORT} -u ${OPENCODE_USERNAME}"
echo ""
echo "Press Ctrl-C to stop."
echo "------------------------------------------------------------"

# --- Run -----------------------------------------------------------------------

export OPENCODE_SERVER_PASSWORD
export OPENCODE_SERVER_USERNAME="${OPENCODE_USERNAME}"

exec opencode serve \
  --hostname "${OPENCODE_HOST}" \
  --port "${OPENCODE_PORT}" \
  --print-logs
