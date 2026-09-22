#!/bin/bash
# Session-start context for a life repo: date/time, days since the last session,
# journal entry and check-in, pending transcripts, undigested journal, uncommitted
# work, and (once a day) whether a newer harness version is published.
# Silent outside a life repo: the plugin is installed user-wide.
root="${CLAUDE_PROJECT_DIR:-$PWD}"
while [ "$root" != "/" ] && [ ! -f "$root/.therapy-harness.json" ]; do root=$(dirname "$root"); done
[ -f "$root/.therapy-harness.json" ] || exit 0
cd "$root"

epoch() { date -j -f "%Y-%m-%d" "$1" +%s 2>/dev/null || date -d "$1" +%s; }
last() { ls -1 "$1" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1 | cut -c1-10; }
days_since() { [ -z "$1" ] && { echo never; return; }; echo $(( ( $(date +%s) - $(epoch "$1") ) / 86400 )); }

echo "Now: $(date "+%A %Y-%m-%d %H:%M")"
ls_=$(last docs/sessions); lj=$(last docs/journal)
d=$(days_since "$ls_"); echo "Last session summary: ${ls_:-none}$([ "$d" != never ] && echo " ($d days ago)")"
d=$(days_since "$lj"); echo "Last journal entry: ${lj:-none}$([ "$d" != never ] && echo " ($d days ago)")"
hour=$(date +%H)
[ "$hour" -lt 5 ] && echo "NOTE: it is after midnight. Apply the state/timing rule: flag heavy conclusions for sober review."
if [ -f docs/transcripts/manifest.json ]; then
  un=$(python3 -c "import json;m=json.load(open('docs/transcripts/manifest.json'));print(sum(1 for v in m.values() if not v.get('summary')))" 2>/dev/null)
  [ -n "$un" ] && [ "$un" != "0" ] && echo "Recordings transcribed but not summarized: $un (run /ingest-recordings)"
fi
lc=$(grep -rl "## Check-in" docs/journal 2>/dev/null | sort | tail -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")
if [ -n "$lc" ]; then d=$(days_since "$lc"); [ "$d" -ge 4 ] && echo "Last check-in: $lc ($d days ago; run /check-in)"; fi
dg=$(grep -m1 "^digested_through:" context/journal-digest.md 2>/dev/null | awk '{print $2}')
und=$(ls docs/journal 2>/dev/null | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$" | sed "s/.md//" | awk -v d="${dg:-0000-00-00}" '$1>d' | wc -l | tr -d " ")
[ "${und:-0}" != "0" ] && echo "Undigested journal entries: $und (run /digest-journal)"
u=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ "$u" != "0" ] && echo "Uncommitted changes: $u files (commit them first)"

# Harness update check, at most once a day (a git fetch of the marketplace clone).
mp="$HOME/.claude/plugins/marketplaces/therapy-agents"
stamp="$HOME/.claude/therapy-harness-update-check"
installed=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "${CLAUDE_PLUGIN_ROOT:-.}/.claude-plugin/plugin.json" 2>/dev/null | head -1)
if [ -d "$mp/.git" ] && [ -n "$installed" ]; then
  if [ ! -f "$stamp" ] || [ $(( $(date +%s) - $(stat -f %m "$stamp" 2>/dev/null || stat -c %Y "$stamp") )) -gt 86400 ]; then
    touch "$stamp"
    ( cd "$mp" && GIT_SSH_COMMAND="ssh -o ConnectTimeout=8" git -c http.lowSpeedLimit=1 -c http.lowSpeedTime=8 fetch -q origin 2>/dev/null ) || true
  fi
  remote=$(cd "$mp" && git show "origin/HEAD:plugins/therapy/.claude-plugin/plugin.json" 2>/dev/null | sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' | head -1)
  if [ -n "$remote" ] && [ "$remote" != "$installed" ] && [ "$(printf '%s\n%s\n' "$installed" "$remote" | sort -V | tail -1)" = "$remote" ]; then
    echo "Therapy harness update available: $installed -> $remote. Tell the owner and offer to run \`therapy update\` (then restart Claude Code)."
  fi
fi
exit 0
