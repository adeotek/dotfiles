#!/usr/bin/env python3
"""Merge a template pi config into an existing live config.

Used by pi-setup.sh when the user chooses to OVERRIDE an existing
~/.pi/agent/<file>.json: instead of a plain `cp` (which would destroy local
customizations such as installed packages, changed defaults, or provider
credentials), this merges template values INTO the live file.

Merge semantics:
  - Objects      : recursive merge; live-only keys are kept (custom config
                   is never dropped)
  - Scalars      : template value wins, unless --live-wins is passed
  - Arrays       : ordered union (live entries first, template-only entries
                   appended, deduplicated) — e.g. the packages list keeps
                   live-only package entries

--live-wins: flip the scalar/conflict preference so the live file wins and
  the template only fills in missing keys. Use for configs the user owns and
  edits (e.g. models.json: a live apiKey value must never be replaced by the
  ${OPENCODE_API_KEY} placeholder).

Notes:
  - Pi reads these files with a strict JSON parser, so templates and live files
    must be plain JSON (no comments, no trailing commas).
  - If the merge changes nothing, the live file is left byte-for-byte intact
    and no backup is written.
  - A timestamped .bak is written next to the live file before replacing it;
    only the newest 5 backups for that file are kept.
  - A live key whose JSON type the template would change is listed on stderr,
    because such a replacement silently rewrites config the user may own.
  - Credentials: pi keeps auth in auth.json, which this script never touches;
    any credential-like key inside the JSON itself survives via the object
    merge (live-only keys are kept).

Usage: merge-pi-config.py [--live-wins] <template> <live>
"""
import glob
import json
import os
import pathlib
import shutil
import sys
import time

BACKUPS_TO_KEEP = 5


def _key(k):
    return json.dumps(k, sort_keys=True)


def type_changes(template, live, path=""):
    """Paths where the template replaces a live value of a different JSON type."""
    changes = []
    if not isinstance(template, dict) or not isinstance(live, dict):
        return changes
    for k, tv in template.items():
        if k not in live:
            continue
        lv = live[k]
        if isinstance(tv, dict) and isinstance(lv, dict):
            changes.extend(type_changes(tv, lv, f"{path}{k}."))
        elif type(tv) is not type(lv):
            changes.append(f"{path}{k} ({type(lv).__name__} -> {type(tv).__name__})")
    return changes


def rotate_backups(live_path):
    """Keep only the newest BACKUPS_TO_KEEP backups of live_path."""
    backups = glob.glob(f"{live_path}.bak.*")
    backups.sort(key=lambda p: int(p.rsplit(".", 1)[1]))
    for old in backups[:-BACKUPS_TO_KEEP]:
        pathlib.Path(old).unlink(missing_ok=True)


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
        if prefer_live:
            # --live-wins: template only fills missing keys; never append entries
            return live
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
            template = json.loads(f.read())
        with open(live_path) as f:
            live = json.loads(f.read())
    except (OSError, json.JSONDecodeError) as e:
        print(f"ERROR: cannot parse configs ({e}); live file left untouched", file=sys.stderr)
        return 1

    if not isinstance(live, dict) or not isinstance(template, dict):
        print("ERROR: a config is not a JSON object; aborting", file=sys.stderr)
        return 1

    merged = merge(template, live, prefer_live)

    if not prefer_live:
        changed = type_changes(template, live)
        if changed:
            print("WARNING: template changes the type of live keys: "
                  + ", ".join(changed), file=sys.stderr)

    if merged == live:
        print(f"no changes: {live_path} already has every template key")
        return 0

    backup = f"{live_path}.bak.{int(time.time() * 1000)}"
    shutil.copyfile(live_path, backup)
    rotate_backups(live_path)

    tmp = f"{live_path}.tmp.{os.getpid()}"
    try:
        with open(tmp, "w") as f:
            f.write(json.dumps(merged, indent=2) + "\n")
        os.replace(tmp, live_path)
    except OSError as e:
        pathlib.Path(tmp).unlink(missing_ok=True)
        print(f"ERROR: cannot write {live_path} ({e}); live file keeps its old content",
              file=sys.stderr)
        return 1

    print(f"merged: {live_path} (backup: {os.path.basename(backup)})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
