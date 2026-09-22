---
name: resume
description: Resume after a context clear by reading HANDOFF.md. Use when the owner says "resume", "pick up where we left off", or right after clearing context.
---
1. Read `HANDOFF.md`. If missing, say so and offer the newest docs/journal
   entry, docs/sessions summary, and `git log --oneline -10` instead.
2. Compare its recorded HEAD with `git rev-parse HEAD`; if commits landed
   since, skim `git log` and re-verify any state claim before relying on it.
3. Do its START HERE list in order, then greet the owner with the live state
   in two or three lines and the next step. Don't delete HANDOFF.md.
