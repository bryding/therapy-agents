"""Shared helpers: locate the life repo and read its .therapy-harness.json."""
import json
import os
import sys
from pathlib import Path

CONFIG_NAME = ".therapy-harness.json"
DEFAULTS = {
    "recordings_remote": "gdrive:Recordings",
    "elevenlabs_key_file": "~/.config/therapy-harness/elevenlabs.env",
    "timezone": None,
    "calendar_id": "primary",
    "allowed_remotes": [],
    "journal_export": "~/Documents/Journal/AppleJournalEntries",
}


def find_root(start=None):
    env = os.environ.get("THERAPY_HOME")
    if env:
        return Path(env).expanduser().resolve()
    p = Path(start or os.getcwd()).resolve()
    for d in [p, *p.parents]:
        if (d / CONFIG_NAME).exists():
            return d
    sys.exit(f"not inside a life repo (no {CONFIG_NAME} here or above). "
             "cd into your life repo, set THERAPY_HOME, or run `therapy new-life <dir>`.")


def config(root=None):
    root = root or find_root()
    cfg = dict(DEFAULTS)
    cfg.update(json.loads((root / CONFIG_NAME).read_text()))
    return cfg


if __name__ == "__main__":
    root = find_root()
    cfg = config(root)
    if len(sys.argv) > 1 and sys.argv[1] == "root":
        print(root)
    elif len(sys.argv) > 2 and sys.argv[1] == "get":
        v = cfg.get(sys.argv[2], "")
        print(json.dumps(v) if isinstance(v, (dict, list)) else v)
    else:
        print(json.dumps(cfg, indent=2, ensure_ascii=False))
