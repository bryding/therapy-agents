#!/usr/bin/env python3
"""Transcribe an audio file with ElevenLabs Scribe (speech-to-text).

Usage:
  elevenlabs_stt.py check                       # verify key works, print nothing secret
  elevenlabs_stt.py transcribe <audio> <out.txt> [--speakers N] [--json out.json]

Key: read from $ELEVENLABS_API_KEY, else from the file named by
"elevenlabs_key_file" in the life repo's .therapy-harness.json (default
~/.config/therapy-harness/elevenlabs.env; one line ELEVENLABS_API_KEY=...).
The key is never printed.
"""
import json
import os
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import harness  # noqa: E402


def key_file():
    try:
        return Path(harness.config()["elevenlabs_key_file"]).expanduser()
    except SystemExit:
        return Path(harness.DEFAULTS["elevenlabs_key_file"]).expanduser()
API = "https://api.elevenlabs.io/v1"


def load_key() -> str:
    k = os.environ.get("ELEVENLABS_API_KEY")
    if k:
        return k.strip()
    kf = key_file()
    if kf.exists():
        for line in kf.read_text().splitlines():
            if line.startswith("ELEVENLABS_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    sys.exit(f"no ElevenLabs key: set ELEVENLABS_API_KEY or create {kf}")


def request(method, path, key, data=None, headers=None, timeout=600):
    h = {"xi-api-key": key}
    if headers:
        h.update(headers)
    req = urllib.request.Request(API + path, data=data, method=method, headers=h)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.status, r.read()


def check(key):
    try:
        status, body = request("GET", "/user/subscription", key)
    except urllib.error.HTTPError as e:
        sys.exit(f"key check failed: HTTP {e.code}")
    d = json.loads(body)
    print(f"key ok: tier={d.get('tier')} chars_used={d.get('character_count')}/{d.get('character_limit')}")


def multipart(fields, file_field, file_path):
    boundary = "----ClaudeSTT" + str(int(time.time()))
    parts = []
    for k, v in fields.items():
        parts.append(f"--{boundary}\r\nContent-Disposition: form-data; name=\"{k}\"\r\n\r\n{v}\r\n".encode())
    fname = Path(file_path).name
    parts.append(
        f"--{boundary}\r\nContent-Disposition: form-data; name=\"{file_field}\"; filename=\"{fname}\"\r\n"
        f"Content-Type: application/octet-stream\r\n\r\n".encode()
    )
    parts.append(Path(file_path).read_bytes())
    parts.append(f"\r\n--{boundary}--\r\n".encode())
    return b"".join(parts), f"multipart/form-data; boundary={boundary}"


def transcribe(key, audio, out_txt, speakers=None, out_json=None):
    fields = {
        "model_id": "scribe_v1",
        "diarize": "true",
        "tag_audio_events": "true",
        "language_code": "eng",
        "timestamps_granularity": "word",
    }
    if speakers:
        fields["num_speakers"] = str(speakers)
    body, ctype = multipart(fields, "file", audio)
    t0 = time.time()
    try:
        status, resp = request("POST", "/speech-to-text", key, data=body,
                               headers={"Content-Type": ctype}, timeout=1800)
    except urllib.error.HTTPError as e:
        sys.exit(f"transcription failed: HTTP {e.code}: {e.read()[:300]!r}")
    d = json.loads(resp)
    if out_json:
        Path(out_json).write_text(json.dumps(d, ensure_ascii=False, indent=1))
    lines = render(d)
    Path(out_txt).write_text("\n".join(lines) + "\n")
    print(f"wrote {out_txt}: {len(lines)} lines, {len(d.get('text',''))} chars, "
          f"{time.time()-t0:.0f}s")


def render(d):
    """Diarized transcript: one paragraph per speaker turn, with [mm:ss] stamps."""
    words = d.get("words") or []
    if not words:
        return [d.get("text", "")]
    lines, cur_spk, cur_words, cur_start = [], None, [], 0.0
    for w in words:
        typ = w.get("type", "word")
        if typ == "audio_event":
            cur_words.append(f"[{w.get('text','').strip('()')}]")
            continue
        spk = w.get("speaker_id", "speaker_0")
        if spk != cur_spk and cur_words:
            lines.append(fmt(cur_spk, cur_start, cur_words))
            cur_words = []
        if not cur_words:
            cur_spk, cur_start = spk, w.get("start", 0.0)
        if typ == "spacing":
            continue
        cur_words.append(w.get("text", ""))
    if cur_words:
        lines.append(fmt(cur_spk, cur_start, cur_words))
    return lines


def fmt(spk, start, words):
    m, s = divmod(int(start), 60)
    label = spk.replace("speaker_", "S") if spk else "S?"
    text = " ".join(words).replace(" ,", ",").replace(" .", ".").replace(" ?", "?").replace(" !", "!")
    return f"[{m:02d}:{s:02d}] {label}: {text}\n"


def main(argv):
    if len(argv) < 2 or argv[1] not in ("check", "transcribe"):
        sys.exit(__doc__)
    key = load_key()
    if argv[1] == "check":
        return check(key)
    if len(argv) < 4:
        sys.exit(__doc__)
    speakers = None
    out_json = None
    rest = argv[4:]
    while rest:
        flag = rest.pop(0)
        if flag == "--speakers":
            speakers = int(rest.pop(0))
        elif flag == "--json":
            out_json = rest.pop(0)
    transcribe(key, argv[2], argv[3], speakers, out_json)


if __name__ == "__main__":
    main(sys.argv)
