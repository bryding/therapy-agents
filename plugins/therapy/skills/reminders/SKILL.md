---
name: reminders
description: Edit or re-sync the owner's daily phone reminders (context/reminders.md -> Google Calendar events with notifications). Use when they want a reminder added/changed/removed, say "update my reminders", or after agreements/patterns change in a way that should change what they're nudged about.
---
1. Read `context/reminders.md`, `context/agreements.md`, `context/patterns.md`.
2. Make the requested change in reminders.md, or after an agreements/patterns
   change propose 1-2 edits. Max 5 daily reminders.
3. Text: under 80 chars, their words, present tense, one action. Never a
   journal quote. Never about another person's behavior; about theirs.
4. Sync with the Google Calendar MCP tools (ToolSearch "calendar"), calendar
   `calendar_id` from `.therapy-harness.json` (default `primary`), timezone
   `timezone`. Each line = one daily recurring 5-minute event
   (RRULE:FREQ=DAILY), popup at 0 min, availability FREE, visibility private,
   description "Growth reminder (context/reminders.md)". Update events in
   place with notifications off. Delete events no longer in the file. Keep
   the event ids in the comment block at the bottom of reminders.md.
5. Commit `Update reminders: <what changed>`.
