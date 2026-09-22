#!/bin/sh
# install.sh — install or update the therapy harness on this machine. Idempotent.
#   curl -fsSL https://raw.githubusercontent.com/bryding/therapy-agents/main/install.sh | sh
#   sh install.sh --local     register THIS checkout instead of GitHub (harness development)
# Uses HTTPS, so no GitHub account or SSH key is needed.
set -eu
MP="therapy-agents"; REPO_URL="https://github.com/bryding/therapy-agents.git"
export CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1
command -v claude >/dev/null 2>&1 || { echo "Install Claude Code first: https://claude.com/claude-code" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "python3 is required." >&2; exit 1; }

SRC="$REPO_URL"
if [ "${1:-}" = "--local" ]; then SRC=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd); fi
if claude plugin marketplace list 2>/dev/null | grep -q "$MP"; then
  claude plugin marketplace update "$MP"
else
  claude plugin marketplace add "$SRC"
fi
claude plugin install "therapy@$MP" 2>/dev/null || claude plugin update "therapy@$MP"

mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/therapy" <<'SHIM'
#!/bin/bash
# shim: run the therapy CLI from the plugin version Claude Code has installed
d=$(python3 - <<'PY' 2>/dev/null
import json, os
p = os.path.expanduser("~/.claude/plugins/installed_plugins.json")
try:
    data = json.load(open(p)).get("plugins", {})
    for e in data.get("therapy@therapy-agents", []):
        if e.get("installPath"): print(e["installPath"]); break
except Exception:
    pass
PY
)
[ -n "$d" ] || d=$(ls -d "$HOME"/.claude/plugins/cache/therapy-agents/therapy/*/ 2>/dev/null | sort -V | tail -1)
[ -n "$d" ] || { echo "therapy harness not installed; run its install.sh" >&2; exit 1; }
exec "${d%/}/bin/therapy" "$@"
SHIM
chmod +x "$HOME/.local/bin/therapy"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "Add ~/.local/bin to your PATH (e.g. in ~/.zshrc)." ;; esac
echo "Done. Restart Claude Code. New life repo: therapy new-life ~/my-life --owner \"Your Name\""
