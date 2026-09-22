---
name: import-journal
description: Import an Apple Journal export folder into docs/journal/. Use when the owner says "import my journal", "I exported Journal", or points at a Journal export folder. Idempotent; re-run after each export.
---
Import Apple Journal entries from the folder in $ARGUMENTS, else from
`journal_export` in `.therapy-harness.json` (`therapy config get journal_export`).

If that folder doesn't exist on this machine, don't search the disk: the
export was probably made on another computer. Ask the owner to paste the
entry, or to copy the export folder to cloud storage you can reach.

1. `therapy import-journal <folder> --dry-run`; show the count and date range.
   If nothing is found, the export layout may have changed: look at the
   folder and fix the importer in the therapy-agents repo (see /update-harness),
   don't hand-copy.
2. Run it for real. Entries land in `docs/journal/YYYY-MM-DD.md` under an
   `## Apple Journal` section; hashes in `docs/journal/.imported.json` prevent
   duplicates. Media is never copied.
3. Undated entries go to `docs/journal/undated.md`: ask for dates, don't guess.
4. Read the new entries. They're raw venting (CLAUDE.md, "Journal voice"):
   don't treat them as beliefs, don't update context/ from them. Give a
   two-line summary of the date range and any recurring theme, then stop.
5. Commit `Import Apple Journal entries YYYY-MM-DD to YYYY-MM-DD`, then run
   /digest-journal.

A pasted entry: append it verbatim to the right day's file, and register its
hash in `.imported.json` (same normalization as the importer) so a later
import doesn't duplicate it.

To export on a Mac: Journal > Settings > Export Journal.
