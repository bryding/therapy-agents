---
name: digest-journal
description: Consume journal entries not yet digested and update context/journal-digest.md, the short rolling summary loaded every session. Use after /import-journal or /journal, when the session-start hook reports undigested entries, or when the owner says "digest the journal".
---
Update `context/journal-digest.md` from undigested entries in `docs/journal/`.

Watermark: the `digested_through:` line at the top of the digest (a date;
entries on that date are included). Every `docs/journal/` file with a later
date is undigested. A full rebuild treats everything as undigested.

1. List undigested files. If none, say so and stop.
2. Read each fully. Don't summarize entry by entry.
3. Rewrite the digest, under ~60 lines:
   - **State of the journal** (3-5 lines): period, arc, where things stood.
   - **Live threads**: 3-8 bullets. Theme, how often (entry count), rising or
     fading, patterns.md number if any. Frequency, not verdicts.
   - **Things they said they want to do** (journal only, dated, unconfirmed
     until they appear in agreements.md).
   - **Open questions** worth raising in a session. Max 5.
   - **Entry index**: one line per entry, newest first. Past ~40 lines,
     collapse entries older than 3 months into one line per month.
4. The journal-voice rule applies hard (CLAUDE.md). Record what shows up and
   how often, never "they believe X." Never promote a journal claim about
   another person into context/.
5. Set `digested_through:` to the newest entry date. Commit
   `Digest journal through YYYY-MM-DD`.
