#!/bin/bash
# therapy doctor: one line per check, OK / WARN / FAIL.
PLUGIN="$1"
ok() { echo "OK    $*"; }; warn() { echo "WARN  $*"; }; fail() { echo "FAIL  $*"; }
command -v claude >/dev/null && ok "claude $(claude --version 2>/dev/null | head -1)" || fail "claude not on PATH"
command -v python3 >/dev/null && ok "python3" || fail "python3 missing"
command -v git >/dev/null && ok "git" || fail "git missing"
v=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$PLUGIN/.claude-plugin/plugin.json" | head -1); ok "harness $v ($PLUGIN)"
root=$(python3 "$PLUGIN/lib/harness.py" root 2>/dev/null)
if [ -z "$root" ]; then warn "not inside a life repo (fine if you're just checking the install)"; exit 0; fi
ok "life repo $root"
cd "$root"
tz=$(python3 "$PLUGIN/lib/harness.py" get timezone); [ -n "$tz" ] && [ "$tz" != "None" ] && ok "timezone $tz" || warn "timezone not set in .therapy-harness.json"
[ -f context/safety.md ] && ok "context/safety.md" || warn "no context/safety.md (run /onboard)"
[ -x .git/hooks/pre-push ] && ok "pre-push guard installed" || warn "no pre-push guard: cp \"$PLUGIN/lib/pre-push\" .git/hooks/ && chmod +x .git/hooks/pre-push"
e=$(git config user.email); case "$e" in *@life.invalid|"") ok "git identity '${e:-unset}'";; *) warn "git email is '$e' (real address in commit metadata)";; esac
[ -d .claude/skills ] && for s in .claude/skills/*/; do n=$(basename "$s"); [ -d "$PLUGIN/skills/$n" ] && warn "repo-local skill '$n' shadows the plugin's"; done
grep -q "session-start" .claude/settings.json 2>/dev/null && warn ".claude/settings.json registers its own session-start hook (double output)"
rem=$(python3 "$PLUGIN/lib/harness.py" get recordings_remote); r=${rem%%:*}
if command -v rclone >/dev/null; then rclone listremotes 2>/dev/null | grep -q "^$r:" && ok "rclone remote $r:" || warn "rclone remote '$r:' not configured (only needed for recordings)"; else warn "rclone not installed (only needed for recordings)"; fi
kf=$(python3 "$PLUGIN/lib/harness.py" get elevenlabs_key_file); kf="${kf/#\~/$HOME}"
[ -f "$kf" ] && ok "ElevenLabs key file present" || warn "no ElevenLabs key at $kf (only needed for recordings)"
