#!/bin/bash
# Session-start context for a life repo. Silent outside one (the plugin is
# installed user-wide). Prints: the core rules (so rule fixes propagate with
# the plugin), the owner's local time, days since the last session / journal /
# check-in, pending work, context files over their size cap, and whether a
# newer harness version is published (fetched in the background, once a day).
root="${CLAUDE_PROJECT_DIR:-$PWD}"
while [ "$root" != "/" ] && [ ! -f "$root/.therapy-harness.json" ]; do root=$(dirname "$root"); done
[ -f "$root/.therapy-harness.json" ] || exit 0
cd "$root"
PLUGIN="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

tz=$(python3 -c "import json;print(json.load(open('.therapy-harness.json')).get('timezone') or '')" 2>/dev/null)
[ -n "$tz" ] && export TZ="$tz"

[ -f "$PLUGIN/rules/core.md" ] && { cat "$PLUGIN/rules/core.md"; echo; echo "---"; }

epoch() { date -j -f "%Y-%m-%d" "$1" +%s 2>/dev/null || date -d "$1" +%s; }
last() { ls -1 "$1" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1 | cut -c1-10; }
days_since() { [ -z "$1" ] && { echo never; return; }; echo $(( ( $(date +%s) - $(epoch "$1") ) / 86400 )); }

echo "Now (owner's local time${tz:+, $tz}): $(date "+%A %Y-%m-%d %H:%M")"
ls_=$(last docs/sessions); lj=$(last docs/journal)
d=$(days_since "$ls_"); echo "Last session summary: ${ls_:-none}$([ "$d" != never ] && echo " ($d days ago)")"
d=$(days_since "$lj"); echo "Last journal entry: ${lj:-none}$([ "$d" != never ] && echo " ($d days ago)")"
hour=$(date +%H)
[ "$hour" -lt 5 ] && echo "NOTE: after midnight for the owner. State/timing rule applies; keep context/safety.md in mind."
if [ -f docs/transcripts/manifest.json ]; then
  un=$(python3 -c "import json;m=json.load(open('docs/transcripts/manifest.json'));print(sum(1 for v in m.values() if not v.get('summary')))" 2>/dev/null)
  [ -n "$un" ] && [ "$un" != "0" ] && echo "Recordings transcribed but not summarized: $un (run /ingest-recordings)"
fi
lc=$(grep -rl "## Check-in" docs/journal 2>/dev/null | sort | tail -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")
if [ -n "$lc" ]; then d=$(days_since "$lc"); [ "$d" -ge 4 ] && echo "Last check-in: $lc ($d days ago; run /check-in)"; fi
dg=$(grep -m1 "^digested_through:" context/journal-digest.md 2>/dev/null | awk '{print $2}')
und=$(ls docs/journal 2>/dev/null | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$" | sed "s/.md//" | awk -v d="${dg:-0000-00-00}" '$1>d' | wc -l | tr -d " ")
[ "${und:-0}" != "0" ] && echo "Undigested journal entries: $und (run /digest-journal)"
[ -f TODO.md ] && { n=$(grep -c '^- \[ \]' TODO.md); [ "$n" -gt 0 ] && echo "Open TODO items: $n (TODO.md, on demand)"; }
[ -f HANDOFF.md ] && echo "HANDOFF.md exists: read it first if resuming work."
for spec in me:40 people:50 patterns:40 agreements:50 safety:15; do
  f="context/${spec%%:*}.md"; cap="${spec#*:}"
  [ -f "$f" ] && { n=$(wc -l < "$f" | tr -d ' '); [ "$n" -gt "$cap" ] && echo "Context over cap: $f $n lines (cap $cap). Offer /rollover."; }
done
[ -f context/safety.md ] || echo "No context/safety.md yet: offer to set it up (/onboard)."
u=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ "$u" != "0" ] && echo "Uncommitted changes: $u files (commit them first)"

# Update check: compare with the last fetched marketplace; refresh in the background.
mp="$HOME/.claude/plugins/marketplaces/therapy-agents"
stamp="$HOME/.claude/therapy-harness-update-check"
installed=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$PLUGIN/.claude-plugin/plugin.json" 2>/dev/null | head -1)
if [ -d "$mp/.git" ] && [ -n "$installed" ]; then
  ref=$(cd "$mp" && for r in origin/HEAD origin/main; do git rev-parse -q --verify "$r" >/dev/null && { echo "$r"; break; }; done)
  remote=$(cd "$mp" && git show "$ref:plugins/therapy/.claude-plugin/plugin.json" 2>/dev/null | sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' | head -1)
  if [ -n "$remote" ] && [ "$remote" != "$installed" ] && [ "$(printf '%s\n%s\n' "$installed" "$remote" | sort -V | tail -1)" = "$remote" ]; then
    echo "Therapy harness update available: $installed -> $remote. Tell the owner and offer \`therapy update\` (then restart Claude Code)."
  fi
  age=86401; [ -f "$stamp" ] && age=$(( $(date +%s) - $(stat -f %m "$stamp" 2>/dev/null || stat -c %Y "$stamp") ))
  if [ "$age" -gt 86400 ]; then
    touch "$stamp"
    ( cd "$mp" && GIT_SSH_COMMAND="ssh -o ConnectTimeout=8 -o BatchMode=yes" GIT_TERMINAL_PROMPT=0 git fetch -q origin >/dev/null 2>&1 & )
  fi
fi
exit 0
