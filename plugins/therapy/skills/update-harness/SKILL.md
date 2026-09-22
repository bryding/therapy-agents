---
name: update-harness
description: Update the therapy harness to the newest published version, or change the harness itself (skills, hook, CLI) and publish it for everyone who uses it. Use when session start reports "Therapy harness update available", when the owner says "update the harness", or when a skill needs fixing or adding.
---
## Getting updates (every user)
`therapy update` (= `claude plugin marketplace update therapy-agents` then
`claude plugin update therapy@therapy-agents`), then restart Claude Code:
skills load at session start only. `therapy version` shows what's installed.

## Changing the harness (maintainers)
Skills don't live in a life repo. They live in the public `therapy-agents`
repo (github.com/bryding/therapy-agents). Find a local checkout (commonly
`~/therapy-agents`; else clone it). Then:

1. Edit `plugins/therapy/skills/<name>/SKILL.md` (or `hooks/`, `bin/`, `lib/`,
   `template/`). Keep everything generic: no names, dates, or facts from
   anyone's life. The repo is public. Personal detail belongs in the life
   repo's CLAUDE.md and context/.
2. `sh bumpVersion.sh therapy [patch|minor|major]`: never hand-edit versions.
   No bump = nobody gets the change.
3. Commit, push. CI checks versions, manifests, and scans for personal data.
4. `therapy update` on each machine, restart sessions. Everyone else is told
   at their next session start.

A life repo can carry its own repo-local `.claude/skills/<name>` for things
that are truly personal; those shadow the plugin's same-named skill, so avoid
reusing plugin skill names.
