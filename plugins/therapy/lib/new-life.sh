#!/bin/bash
# new-life.sh <plugin-root> <dir> --owner NAME [--partner NAME] [--therapist NAME] [--couples NAME]
set -euo pipefail
PLUGIN="$1"; shift
DIR="${1:?usage: therapy new-life <dir> --owner NAME}"; shift
OWNER=""; PARTNER=""; THERAPIST=""; COUPLES=""
while [ $# -gt 0 ]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --partner) PARTNER="$2"; shift 2 ;;
    --therapist) THERAPIST="$2"; shift 2 ;;
    --couples) COUPLES="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 1 ;;
  esac
done
[ -n "$OWNER" ] || { echo "--owner is required" >&2; exit 1; }
[ -e "$DIR" ] && [ -n "$(ls -A "$DIR" 2>/dev/null)" ] && { echo "$DIR exists and is not empty" >&2; exit 1; }
mkdir -p "$DIR"
cp -R "$PLUGIN/template/." "$DIR/"
python3 - "$DIR" "$OWNER" "$PARTNER" "$THERAPIST" "$COUPLES" <<'PY'
import json, sys, pathlib, os

def local_tz():
    try:
        return os.path.realpath('/etc/localtime').split('zoneinfo/')[1]
    except Exception:
        return 'UTC'
d, owner, partner, therapist, couples = sys.argv[1:]
root = pathlib.Path(d)
cfg = json.loads((root / ".therapy-harness.json").read_text())
cfg.update(owner=owner, partner=partner or None, timezone=cfg.get("timezone") or local_tz(),
           therapists={"individual": therapist or None, "couples": couples or None})
(root / ".therapy-harness.json").write_text(json.dumps(cfg, indent=2) + "\n")
for p in root.rglob("*.md"):
    t = p.read_text()
    t = t.replace("{{OWNER}}", owner).replace("{{PARTNER}}", partner or "(partner)")
    t = t.replace("{{THERAPIST}}", therapist or "(therapist)").replace("{{COUPLES}}", couples or "(couples therapist)")
    p.write_text(t)
PY
cd "$DIR"
[ -d .git ] || git init -q -b main
slug=$(printf '%s' "$OWNER" | tr 'A-Z ' 'a-z-' | tr -cd 'a-z0-9-')
git config user.name "$OWNER"
git config user.email "${slug:-owner}@life.invalid"
cp "$PLUGIN/lib/pre-push" .git/hooks/pre-push && chmod +x .git/hooks/pre-push
git add -A && git commit -qm "Start life repo from therapy-agents template" || true
echo "Created $DIR. Next: cd $DIR && claude, then run /onboard."
