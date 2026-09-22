#!/bin/sh
# bumpVersion.sh — bump a plugin's version everywhere it is recorded.
#
# A plugin's version lives in TWO files that must stay equal:
#   plugins/<plugin>/.claude-plugin/plugin.json
#   .claude-plugin/marketplace.json (that plugin's entry)
# Installed plugins only refresh on a version change, so an edit without a bump
# publishes nothing ("already at the latest version"). This is the only
# sanctioned way to change a version.
#
#   sh bumpVersion.sh <plugin> [patch|minor|major]   bump (default: patch)
#   sh bumpVersion.sh --check                        verify all plugins agree; exit 1 if not
#
# Edits use sed so only the matched bytes change (the manifests carry em dashes;
# don't round-trip them through a JSON serializer).
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd); cd "$ROOT"
MARKETPLACE=".claude-plugin/marketplace.json"

manifest_version() { sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$1" 2>/dev/null | head -1; }
marketplace_version() {
  sed -n "/\"name\": \"$1\"/,/\"version\"/p" "$MARKETPLACE" | sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' | head -1
}
plugin_names() { ls -d plugins/*/ 2>/dev/null | sed 's|plugins/||;s|/||'; }
sed_in_place() { case "$(uname -s)" in Darwin) sed -i '' "$1" "$2" ;; *) sed -i "$1" "$2" ;; esac; }

check_all() {
  rc=0
  for p in $(plugin_names); do
    a=$(manifest_version "plugins/$p/.claude-plugin/plugin.json"); b=$(marketplace_version "$p")
    if [ -n "$a" ] && [ "$a" = "$b" ]; then printf '  %-12s %s  OK\n' "$p" "$a"
    else printf '  %-12s plugin=%s marketplace=%s  MISMATCH\n' "$p" "${a:-MISSING}" "${b:-MISSING}"; rc=1; fi
  done
  return $rc
}

case "${1:-}" in
  --help|-h|"") sed -n '2,15p' "$0"; [ -n "${1:-}" ] && exit 0 || exit 1 ;;
  --check) echo "version consistency:"; check_all && { echo "all plugins consistent"; exit 0; }
           echo "ERROR: version mismatch; fix before publishing" >&2; exit 1 ;;
esac

PLUGIN="$1"; PART="${2:-patch}"; M="plugins/$PLUGIN/.claude-plugin/plugin.json"
[ -f "$M" ] || { echo "ERROR: no such plugin '$PLUGIN'" >&2; exit 1; }
CUR=$(manifest_version "$M")
MAJOR=${CUR%%.*}; REST=${CUR#*.}; MINOR=${REST%%.*}; PATCH=${REST#*.}
case "$PART" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
  *) echo "ERROR: part must be patch, minor, or major" >&2; exit 1 ;;
esac
NEW="$MAJOR.$MINOR.$PATCH"
sed_in_place "s/\"version\": \"$CUR\"/\"version\": \"$NEW\"/" "$M"
sed_in_place "/\"name\": \"$PLUGIN\"/,/\"version\"/ s/\"version\": \"[^\"]*\"/\"version\": \"$NEW\"/" "$MARKETPLACE"
echo "$PLUGIN: $CUR -> $NEW ($PART)"
check_all && echo "Next: commit + push. Users get it via 'therapy update' (or it's offered at session start)."
