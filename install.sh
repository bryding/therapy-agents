#!/bin/sh
# install.sh — one-time (and idempotent) setup of the therapy harness on a machine.
#   sh install.sh            register the marketplace from GitHub, install/update the plugin,
#                            and put the `therapy` command in ~/.local/bin
#   sh install.sh --local    same, but register THIS checkout (for developing the harness)
set -eu
MP="therapy-agents"; REPO="bryding/therapy-agents"
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
command -v claude >/dev/null 2>&1 || { echo "Install Claude Code first: https://claude.com/claude-code" >&2; exit 1; }

SRC="$REPO"; [ "${1:-}" = "--local" ] && SRC="$HERE"
if claude plugin marketplace list 2>/dev/null | grep -q "$MP"; then
  claude plugin marketplace update "$MP"
else
  claude plugin marketplace add "$SRC"
fi
claude plugin install "therapy@$MP" 2>/dev/null || claude plugin update "therapy@$MP"

mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/therapy" <<'SHIM'
#!/bin/bash
# shim: run the newest installed version of the therapy harness CLI
d=$(ls -d "$HOME"/.claude/plugins/cache/therapy-agents/therapy/*/ 2>/dev/null | sort -V | tail -1)
[ -n "$d" ] || { echo "therapy harness not installed; run install.sh from the therapy-agents repo" >&2; exit 1; }
exec "$d/bin/therapy" "$@"
SHIM
chmod +x "$HOME/.local/bin/therapy"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "Add ~/.local/bin to your PATH." ;; esac
echo "Done. Restart Claude Code. Start a new life repo with: therapy new-life ~/my-life --owner <Name>"
