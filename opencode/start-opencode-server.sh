#!/usr/bin/env bash
#
# Start the OpenCode v2 backend (`opencode serve`) so clients on another host
# can connect to it over the LAN.
#
# Settings resolve in this order (highest precedence first):
#   1. command-line arguments
#   2. environment variables, including any sourced from the env file
#   3. the built-in defaults shown below
#
# This script targets OpenCode v2 only.
#
# Usage:
#   start-opencode-server.sh [options] [-- <extra `opencode serve` flags>]

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Start the OpenCode v2 backend (opencode serve) for LAN clients.

Usage:
  start-opencode-server.sh [options] [-- <extra opencode serve flags>]

Options:
  -h, --help               Show this help and exit.
  -H, --hostname <host>    Listen address.              [OPENCODE_HOST=0.0.0.0]
  -p, --port <port>        Listen port.                 [OPENCODE_PORT=4096]
      --password <secret>  Server password. If unset, `opencode serve`
                           generates one and prints it.  [OPENCODE_SERVER_PASSWORD]
      --cors <origin>      Allow a browser origin; repeatable.
                           [OPENCODE_CORS="http://a:1,https://b"]
      --env-file <path>    Env file to source first.     [OPENCODE_ENV_FILE=<dir>/.env]
      --print-logs         Print server logs (default).  [OPENCODE_PRINT_LOGS=true]
      --no-print-logs      Do not print server logs.
  --                       Forward the remaining flags to `opencode serve`
                           (for example --service or --stdio).

Precedence: arguments > environment (including the env file) > defaults.

Connect a terminal client (run on the client machine):
  opencode --server http://<this-host>:<port>

Pair the web UI / desktop app (run on this host):
  opencode pair --url http://<this-host>:<port>
EOF
}

# --- Parse arguments -----------------------------------------------------------

OPT_HOST=""
OPT_PORT=""
OPT_PASSWORD=""
OPT_ENV_FILE=""
OPT_PRINT_LOGS=""
declare -a OPT_CORS=()
declare -a FORWARD=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -H|--hostname)
      [[ -n "${2:-}" ]] || { echo "ERROR: --hostname needs a value." >&2; exit 2; }
      OPT_HOST="$2"; shift 2
      ;;
    -p|--port)
      [[ -n "${2:-}" ]] || { echo "ERROR: --port needs a value." >&2; exit 2; }
      OPT_PORT="$2"; shift 2
      ;;
    --password)
      [[ -n "${2:-}" ]] || { echo "ERROR: --password needs a value." >&2; exit 2; }
      OPT_PASSWORD="$2"; shift 2
      ;;
    --cors)
      [[ -n "${2:-}" ]] || { echo "ERROR: --cors needs a value." >&2; exit 2; }
      OPT_CORS+=("$2"); shift 2
      ;;
    --env-file)
      [[ -n "${2:-}" ]] || { echo "ERROR: --env-file needs a value." >&2; exit 2; }
      OPT_ENV_FILE="$2"; shift 2
      ;;
    --print-logs)    OPT_PRINT_LOGS=true;  shift ;;
    --no-print-logs) OPT_PRINT_LOGS=false; shift ;;
    --)
      shift
      FORWARD=("$@")
      break
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      echo "" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# --- Load environment ----------------------------------------------------------

# Source the env file first so its variables sit below the explicit arguments.
env_file="${OPT_ENV_FILE:-${OPENCODE_ENV_FILE:-${script_dir}/.env}}"
if [[ -f "$env_file" ]]; then
  # shellcheck disable=SC1090
  source "$env_file"
elif [[ -n "${OPT_ENV_FILE:-}" || -n "${OPENCODE_ENV_FILE:-}" ]]; then
  echo "ERROR: env file not found: ${env_file}" >&2
  exit 1
fi

# Resolution: argument > environment > default.
HOST="${OPT_HOST:-${OPENCODE_HOST:-0.0.0.0}}"
PORT="${OPT_PORT:-${OPENCODE_PORT:-9991}}"
PASSWORD="${OPT_PASSWORD:-${OPENCODE_SERVER_PASSWORD:-}}"

declare -a CORS=()
if [[ ${#OPT_CORS[@]} -gt 0 ]]; then
  CORS=("${OPT_CORS[@]}")
elif [[ -n "${OPENCODE_CORS:-}" ]]; then
  IFS=', ' read -r -a CORS <<< "${OPENCODE_CORS}"
fi

PRINT_LOGS="${OPT_PRINT_LOGS:-${OPENCODE_PRINT_LOGS:-true}}"
case "${PRINT_LOGS,,}" in
  false|0|no|off) PRINT_LOGS=false ;;
  *)              PRINT_LOGS=true ;;
esac

# --- Pre-flight ----------------------------------------------------------------

command -v opencode >/dev/null 2>&1 || {
  echo "ERROR: 'opencode' not found on PATH." >&2
  exit 1
}

OC_MAJOR="$(opencode --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)"
if [[ "${OC_MAJOR:-}" != "2" ]]; then
  echo "ERROR: OpenCode v2 is required, found: $(opencode --version 2>/dev/null || echo unknown)." >&2
  exit 1
fi

if command -v ss >/dev/null 2>&1; then
  if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE "[:.]${PORT}\$"; then
    echo "ERROR: port ${PORT} is already in use." >&2
    exit 1
  fi
fi

# --- Assemble the command ------------------------------------------------------

declare -a serve_args=(serve --hostname "$HOST" --port "$PORT")
if [[ ${#CORS[@]} -gt 0 ]]; then
  for origin in "${CORS[@]}"; do
    if [[ -n "$origin" ]]; then
      serve_args+=(--cors "$origin")
    fi
  done
fi
if [[ "$PRINT_LOGS" == true ]]; then
  serve_args+=(--print-logs)
fi
if [[ ${#FORWARD[@]} -gt 0 ]]; then
  serve_args+=("${FORWARD[@]}")
fi

# --- Connection info -----------------------------------------------------------

echo "Starting opencode serve…"
echo "  hostname: ${HOST}"
echo "  port:     ${PORT}"
if [[ -n "$PASSWORD" ]]; then
  echo "  password: set"
else
  echo "  password: <generated by opencode serve, printed below>"
fi
echo ""
echo "Reachable at (use one of these from the client machine):"
while IFS= read -r ip; do
  if [[ -n "$ip" ]]; then
    echo "  http://${ip}:${PORT}"
  fi
done < <(hostname -I 2>/dev/null | tr ' ' '\n' || true)
echo "  http://localhost:${PORT}"
echo ""
echo "  client:  opencode --server http://<this-host>:${PORT}"
echo "  pairing: opencode pair --url http://<this-host>:${PORT}"
echo ""
echo "Press Ctrl-C to stop."
echo "------------------------------------------------------------"

# --- Run -----------------------------------------------------------------------

if [[ -n "$PASSWORD" ]]; then
  export OPENCODE_SERVER_PASSWORD="$PASSWORD"
fi

exec opencode "${serve_args[@]}"
