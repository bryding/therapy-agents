---
name: journal
description: Write a journal entry with the owner of this life repo. Use when they want to journal, process something, vent, think out loud about their day, a fight, a feeling, or a decision; or say "journal", "entry", "let me get this down", or just start narrating what happened.
---
Journal entry to `docs/journal/YYYY-MM-DD.md` (append a `## HH:MM` section if
the file already exists today).

1. Ask nothing up front unless the entry is empty. Let them write or talk. If
   $ARGUMENTS has content, that IS the entry; go to step 2. Dictated entries
   misspell names: fix them from context/people.md, never guess.
2. Header for each entry: time of day and a one-line **State** note. Ask
   plainly if not stated: any substances in the last ~12 hours? Sleep? If it's
   after midnight or they're not sober, add
   `> State flag: review sober / in daylight` at the top. Not judgment; the
   state/timing rule.
3. Write the entry in their voice, near-verbatim. Don't clean up or soften it.
4. Below it, a short **Reflection** (5-10 lines max):
   - Reflect back what you actually heard, including what they didn't say.
   - Name any pattern from context/patterns.md by number if it's present.
   - If a conclusion is being reached about a partner, a friend, or a big
     decision, do NOT ratify it. Ask the one question that tests it.
   - No fixing, no action plans unless asked.
   - If they say they're hurting, lead with warmth, keep the honest part to
     one point, and ask about safety plainly if there's any risk signal.
5. If the entry makes or breaks a commitment in context/agreements.md, say so
   and offer to update it. Don't do it silently.
6. If anything here belongs in a message to someone, say "this is venting, not
   a letter" and point at /letter for later.

Commit when done (see CLAUDE.md, Git). Then run /digest-journal.
