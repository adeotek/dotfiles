#!/usr/bin/env python3
"""Merge a template opencode config into an existing live config.

Used by opencode-setup.sh when the user chooses to OVERRIDE an existing
~/.config/opencode/*.jsonc: instead of a plain `cp` (which would destroy
local customizations such as extra plugins, provider options, web UI
host/auth, or embedded credentials), this merges template values INTO the
live file.

Merge semantics:
  - Objects      : recursive merge; live-only keys are kept (custom config
                   is never dropped)
  - Scalars      : template value wins, unless --live-wins is passed
  - Arrays       : ordered union (live entries first, template-only entries
                   appended, deduplicated) — e.g. the plugin list keeps
                   live-only plugins like ./plugins/graphify.js

--live-wins: flip the scalar/conflict preference so the live file wins and
  the template only fills in missing keys. Use for configs the user owns and
  edits (e.g. opencode-mem.jsonc: webServerHost/webServerAuth*) where the
  live values must never be reset to the template defaults.

Notes:
  - JSONC comments are stripped (they are documentation; the template keeps
    them). The merged file is plain pretty-printed JSON, valid for OpenCode.
  - If the merge changes nothing, the live file is left byte-for-byte intact
    (so its comments survive) and no backup is written.
  - A timestamped .bak is written next to the live file before replacing it.
  - Credentials: OpenCode keeps auth (API keys, OAuth) in auth.json, which
    this script never touches; any credential-like key inside the jsonc
    itself survives via the object merge (live-only keys are kept).

Usage: merge-opencode-config.py [--live-wins] <template> <live>
"""
import json
import os
import re
import sys
import time


def strip_jsonc(text: str) -> str:
    """Remove // and /* */ comments outside strings (state machine)."""
    out, i, n = [], 0, len(text)
    in_str, esc = False, False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
        elif c == "/" and i + 1 < n and text[i + 1] == "/":
            while i < n and text[i] != "\n":
                i += 1
        elif c == "/" and i + 1 < n and text[i + 1] == "*":
            i += 2
            while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def _key(k):
    return json.dumps(k, sort_keys=True)


def merge(template, live, prefer_live=False):
    """Deep merge: live-only content kept; conflict winner depends on mode."""
    if isinstance(template, dict) and isinstance(live, dict):
        result = dict(live)  # live-only keys survive untouched
        for k, tv in template.items():
            if k in live:
                result[k] = merge(tv, live[k], prefer_live)
            else:
                result[k] = tv
        return result
    if isinstance(template, list) and isinstance(live, list):
        # ordered union, dedup by normalized JSON value
        seen = {_key(x) for x in live}
        result = list(live)
        for x in template:
            if _key(x) not in seen:
                result.append(x)
                seen.add(_key(x))
        return result
    # scalar / type mismatch: template wins unless --live-wins
    return live if prefer_live else template


def main():
    prefer_live = "--live-wins" in sys.argv[1:]
    paths = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(paths) != 2:
        print(f"usage: {sys.argv[0]} [--live-wins] <template> <live>", file=sys.stderr)
        return 2
    tpl_path, live_path = paths

    try:
        with open(tpl_path) as f:
            template = json.loads(strip_jsonc(f.read()))
        with open(live_path) as f:
            live = json.loads(strip_jsonc(f.read()))
    except (OSError, json.JSONDecodeError) as e:
        print(f"ERROR: cannot parse configs ({e}); live file left untouched", file=sys.stderr)
        return 1

    merged = merge(template, live, prefer_live)

    # safety net: never drop a live-only top-level key
    dropped = [k for k in live if k not in merged]
    if dropped:
        print(f"ERROR: merge would drop live keys {dropped}; aborting", file=sys.stderr)
        return 1

    if merged == live:
        print(f"no changes: {live_path} already has every template key")
        return 0

    backup = f"{live_path}.bak.{int(time.time())}"
    with open(backup, "w") as f:
        f.write(open(live_path).read())

    tmp = f"{live_path}.tmp.{os.getpid()}"
    with open(tmp, "w") as f:
        f.write(json.dumps(merged, indent=2) + "\n")
    os.replace(tmp, live_path)

    print(f"merged: {live_path} (backup: {os.path.basename(backup)})")
    return 0


if __name__ == "__main__":
    sys.exit(main())