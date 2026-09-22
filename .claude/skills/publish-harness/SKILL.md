---
name: publish-harness
description: Maintainer workflow for changing and publishing the therapy harness (this repo). Use when editing skills, the hook, the CLI, the rules, or the template here.
---
1. Edit under `plugins/therapy/`. Generic only: no names, dates, quotes or
   facts from anyone's life (public repo). The pre-commit hook scans staged
   changes against `~/.config/therapy-harness/denylist` (one term per line,
   never committed); install it once with `git config core.hooksPath .githooks`.
2. `sh bumpVersion.sh therapy [patch|minor|major]` (minor for rule or template
   changes). Never hand-edit versions; no bump = nothing publishes.
3. Commit, push, CI must pass. `therapy update` on each machine; everyone else
   is told at their next session start (checked daily).
