---
name: summarize-session
description: Summarize a raw therapy/couples/conversation transcript into the docs/sessions/ format. Use when a new transcript lands in docs/transcripts/, the owner says "summarize this session", or pastes/points at a transcript.
---
Summarize the transcript at $ARGUMENTS (or the newest in `docs/transcripts/`)
into `docs/sessions/YYYY-MM-DD_<source>.md`.

1. Read the whole transcript. Diarization labels are unreliable: attribute by
   content and say so; flag genuinely ambiguous lines in a caveat.
2. Format (match the newest existing summary if there is one):
   - Header: date and time, participants with label mapping, setting,
     substances if any, consent (was recording asked/known?), state flag,
     previous session.
   - Thematic sections with near-verbatim key quotes and `[mm:ss]` stamps.
     Give every person's words the same precision; another person's words on
     tape are primary sources about them, the owner's characterizations of
     them are not.
   - "Observations for Integration": what went well / what to watch for each
     person (from tape only) / the therapist for the record / suggested agenda.
   - "Proposed context changes" and "Agreements made".
3. Honest, not flattering. Name patterns from context/patterns.md by number.
   Note anything that contradicts or revises an earlier document.
4. Substance-assisted or after-2-AM: mark conclusions as needing sober review.
5. Update docs/index.md. Propose (don't silently apply) changes to agreements
   or patterns; under /ingest-recordings the driver applies context edits,
   never patterns.md. Never edit the transcript. Never quote phone numbers,
   addresses, or credentials heard on tape.

Commit when done (see CLAUDE.md, Git).
