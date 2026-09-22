---
name: update-harness
description: Update the therapy harness to the newest published version, or check the install. Use when session start reports "Therapy harness update available", or the owner says "update the harness", "is my harness up to date", or something in the harness seems broken.
---
1. `therapy version` shows what's installed. `therapy doctor` checks the
   machine and this life repo and says what to fix.
2. `therapy update` pulls the newest harness and installs it. Then the owner
   restarts Claude Code (skills and rules load at session start only).
3. If a skill seems wrong or missing, don't patch it here: skills live in the
   public therapy-agents repo, not in the life repo. Write the problem down
   in TODO.md (what happened, which skill, no personal details) so the owner
   can pass it to whoever maintains the harness. A repo-local
   `.claude/skills/<name>` works for something truly personal, but don't
   reuse a plugin skill's name: it would shadow the plugin's version.
4. The template (CLAUDE.md, context/ files) only seeds new repos. If the
   update notes mention template changes, offer to port them by hand.
