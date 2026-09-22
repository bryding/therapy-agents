#!/usr/bin/env python3
"""Ingest new voice recordings: Google Drive -> ElevenLabs -> docs/transcripts/.

Usage:
  ingest_recordings.py list                 # show Drive folder vs manifest (no side effects)
  ingest_recordings.py run [--limit N]      # download + transcribe everything not in the manifest
  ingest_recordings.py local <audio> [--title T] [--date YYYY-MM-DD] [--speakers N]
                                            # transcribe a file already on disk (no Drive)

Drive access is via rclone (remote configured once per machine: `rclone config`,
type drive, name "gdrive"). The folder is "recordings_remote" in
.therapy-harness.json (default gdrive:Recordings); RECORDINGS_REMOTE overrides.
Run from anywhere inside a life repo.

State: docs/transcripts/manifest.json maps Drive file id -> transcript path.
Audio is kept locally in docs/transcripts/audio/ (gitignored via *.m4a).
Transcripts are versioned. Nothing here edits an existing transcript.
"""
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import harness  # noqa: E402

ROOT = harness.find_root()
TRANSCRIPTS = ROOT / "docs/transcripts"
AUDIO = TRANSCRIPTS / "audio"
MANIFEST = TRANSCRIPTS / "manifest.json"
REMOTE = __import__("os").environ.get("RECORDINGS_REMOTE") or harness.config(ROOT)["recordings_remote"]
STT = Path(__file__).resolve().parent / "elevenlabs_stt.py"

MONTHS = {m: i for i, m in enumerate(
    ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"], 1)}


def load_manifest():
    return json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {}


def save_manifest(m):
    MANIFEST.write_text(json.dumps(m, indent=2, ensure_ascii=False, sort_keys=True) + "\n")


def rclone_list():
    try:
        out = subprocess.run(["rclone", "lsjson", REMOTE], check=True, capture_output=True, text=True).stdout
    except FileNotFoundError:
        sys.exit("rclone not installed (brew install rclone)")
    except subprocess.CalledProcessError as e:
        sys.exit(f"rclone lsjson {REMOTE} failed: {e.stderr.strip()}\n"
                 "Has `rclone config` (type: drive, name: gdrive) been run on this machine?")
    files = [f for f in json.loads(out) if not f.get("IsDir")]
    return sorted(files, key=lambda f: f.get("ModTime", ""))


def derive_name(title: str, mod_time: str):
    """'Sep 6 at 8-14 PM.m4a' -> ('2026-09-06', 'rec-2014')
       'Sep 9 friend convo 1.m4a' -> ('2026-09-09', 'friend-convo-1')
       'Hard talk with partner .m4a' -> (<modtime date>, 'hard-talk-with-partner')"""
    stem = re.sub(r"\.[A-Za-z0-9]+$", "", title).strip()
    year = (mod_time or datetime.now().isoformat())[:4]
    date = (mod_time or datetime.now().isoformat())[:10]
    m = re.match(r"^([A-Za-z]{3})[a-z]*\s+(\d{1,2})(?:\s+at\s+(\d{1,2})-(\d{2})\s*(AM|PM))?\s*(.*)$", stem, re.I)
    slug_src = stem
    if m and m.group(1).lower()[:3] in MONTHS:
        mon = MONTHS[m.group(1).lower()[:3]]
        date = f"{year}-{mon:02d}-{int(m.group(2)):02d}"
        rest = m.group(6).strip()
        if m.group(3):
            h, mi, ap = int(m.group(3)), m.group(4), m.group(5).upper()
            h = h % 12 + (12 if ap == "PM" else 0)
            slug_src = rest or f"rec {h:02d}{mi}"
        else:
            slug_src = rest or "rec"
    slug = re.sub(r"[^a-z0-9]+", "-", slug_src.lower()).strip("-") or "rec"
    return date, slug


def unique_path(date, slug, ext=".txt"):
    p = TRANSCRIPTS / f"{date}_{slug}{ext}"
    n = 2
    while p.exists():
        p = TRANSCRIPTS / f"{date}_{slug}-{n}{ext}"
        n += 1
    return p


def transcribe(audio: Path, out_txt: Path, speakers=None):
    cmd = [sys.executable, str(STT), "transcribe", str(audio), str(out_txt),
           "--json", str(out_txt.with_suffix(".words.json"))]
    if speakers:
        cmd += ["--speakers", str(speakers)]
    subprocess.run(cmd, check=True)


def cmd_list():
    m = load_manifest()
    files = rclone_list()
    new = [f for f in files if f["ID"] not in m]
    print(f"{REMOTE}: {len(files)} files, {len(files)-len(new)} in manifest, {len(new)} new")
    for f in new:
        d, s = derive_name(f["Name"], f.get("ModTime", ""))
        print(f"  NEW  {f['Size']/1e6:6.1f} MB  {f['Name']!r:45} -> {d}_{s}.txt")
    return new


def cmd_run(limit=None):
    AUDIO.mkdir(parents=True, exist_ok=True)
    m = load_manifest()
    new = cmd_list()
    if limit:
        new = new[:limit]
    done = []
    for f in new:
        date, slug = derive_name(f["Name"], f.get("ModTime", ""))
        out_txt = unique_path(date, slug)
        local = AUDIO / f"{out_txt.stem}{Path(f['Name']).suffix or '.m4a'}"
        if not local.exists():
            print(f"downloading {f['Name']!r} -> {local.name}")
            subprocess.run(["rclone", "copyto", f"{REMOTE}/{f['Name']}", str(local)], check=True)
        print(f"transcribing {local.name} ({f['Size']/1e6:.1f} MB)")
        transcribe(local, out_txt)
        m[f["ID"]] = {
            "title": f["Name"], "size": f["Size"], "drive_modified": f.get("ModTime"),
            "audio": str(local.relative_to(ROOT)), "transcript": str(out_txt.relative_to(ROOT)),
            "transcribed_at": datetime.now().astimezone().isoformat(timespec="seconds"),
            "summary": None,
        }
        save_manifest(m)
        done.append(out_txt)
    print(f"\n{len(done)} new transcript(s):")
    for p in done:
        print(f"  {p.relative_to(ROOT)}")
    if done:
        print("\nNext: /summarize-session each of the above; then set manifest 'summary' to the summary path.")


def cmd_local(audio, title=None, date=None, speakers=None):
    audio = Path(audio)
    d, slug = derive_name(title or audio.name, "")
    if date:
        d = date
    out_txt = unique_path(d, slug)
    transcribe(audio, out_txt, speakers)
    print(f"transcript: {out_txt.relative_to(ROOT)} (not in Drive manifest; add by hand if it came from Drive)")


def main(argv):
    if len(argv) < 2 or argv[1] not in ("list", "run", "local"):
        sys.exit(__doc__)
    if argv[1] == "list":
        cmd_list()
    elif argv[1] == "run":
        limit = int(argv[argv.index("--limit") + 1]) if "--limit" in argv else None
        cmd_run(limit)
    else:
        args = argv[2:]
        audio = args.pop(0)
        opts = {}
        while args:
            k = args.pop(0)
            opts[k.lstrip("-")] = args.pop(0)
        cmd_local(audio, opts.get("title"), opts.get("date"),
                  int(opts["speakers"]) if "speakers" in opts else None)


if __name__ == "__main__":
    main(sys.argv)
