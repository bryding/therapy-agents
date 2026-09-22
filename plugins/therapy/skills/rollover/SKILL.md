---
name: rollover
description: Keep always-loaded context small. Move dated history out of context/ files that are over their size cap into context/archive/ or the session docs that already hold it. Use when the session-start hook reports a file over cap, monthly, or when the owner says "trim my context".
---
Caps (CLAUDE.md): me 40, people 50, patterns 40, agreements 50, safety 15.

1. For each file over cap, propose the cut before making it: which dated
   blocks move, where they go (`context/archive/YYYY-MM_<file>.md`, or an
   existing `docs/sessions/...` that already records it), and what the
   one-line replacement in the live file says.
2. Keep current facts, live agreements, and anything the owner's next week
   depends on. Move history, superseded states, and long quotes.
3. For every fact dropped from a live file, verify it exists somewhere in
   `docs/` or the archive before deleting it. Nothing is lost, only moved.
4. Never touch patterns.md here (/review-patterns only). Never rewrite
   meaning while moving; move text verbatim.
5. Add a dated line to `context/timeline.md` for anything that was a turning
   point. One commit per file: `Rollover <file>: moved <what> to <where>`.
