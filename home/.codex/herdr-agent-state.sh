#!/bin/sh
# Bridges Codex SessionStart hooks into Herdr when run from a Herdr pane.
set -eu

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0

input_file="$(mktemp "${TMPDIR:-/tmp}/herdr-codex-hook.XXXXXX")" || exit 0
trap 'rm -f "$input_file"' EXIT HUP INT TERM
cat >"$input_file" 2>/dev/null || true

python3 - "$input_file" <<'PY'
import json, os, random, socket, sys, time
try:
    event = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    event = {}
session_id = event.get("session_id")
if not isinstance(session_id, str) or not session_id:
    raise SystemExit(0)
if os.environ.get("CODEX_THREAD_ID") not in (None, session_id):
    raise SystemExit(0)
request = {
    "id": f"herdr:codex:{time.time_ns()}:{random.randrange(1_000_000):06d}",
    "method": "pane.report_agent_session",
    "params": {
        "pane_id": os.environ["HERDR_PANE_ID"], "source": "herdr:codex",
        "agent": "codex", "seq": time.time_ns(), "agent_session_id": session_id,
    },
}
try:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(0.5)
        client.connect(os.environ["HERDR_SOCKET_PATH"])
        client.sendall((json.dumps(request) + "\n").encode())
except OSError:
    pass
PY
