---
name: onboard
description: First-run setup of a life repo, or review of a seeded one. Interview the owner and fill context/ (me, people, patterns, agreements, safety). Use right after `therapy new-life`, when context/ is mostly placeholders, when a SEED.md exists, or when the owner says "set me up", "onboard me", "start my harness".
---
Goal: a context/ the owner recognizes as true, in one sitting, without it
feeling like an intake form. Stop whenever they want; pick up next time.

1. Read CLAUDE.md, `.therapy-harness.json`, everything in context/.
2. **Safety first.** If `context/safety.md` has placeholders, fill it before
   anything else: crisis line for their country, therapist contact, one
   person they can call any hour, what helps, what makes it worse.
3. **Seeded repo.** If `SEED.md` exists, the repo was started from someone
   else's records. Tell the owner plainly: who seeded it, from what, and
   that nothing in it counts as true until they confirm it. Walk it section
   by section (SEED.md lists every seeded item with its source, date, state,
   and whether consent to record was audible). For each: keep, correct, or
   delete. Delete rejected items without argument. When done, move SEED.md
   to `docs/seed-review.md` with their decisions, and commit.
4. **Interview**, a few questions at a time: who they are and what's going on
   now; the people who matter; what would make this worth using in three
   months; what they already know about their own patterns; commitments
   already in play; sleep and substances, asked plainly, without judgment.
5. Write answers into context/ in their words, under the size caps in
   CLAUDE.md. Patterns: only what they name or confirm; anything else is
   "candidate".
6. Ask how they want you to be (blunt or gentle, what to do when they say
   they're hurting, what's off limits). Write it under `## Mine` in
   CLAUDE.md. Core rules come from the plugin; don't copy them in.
7. Offer optional pieces; set up only what they say yes to: recordings
   (rclone + ElevenLabs key file), Apple Journal import, phone reminders,
   an encrypted remote (add it to `allowed_remotes`). Run `therapy doctor`.
8. Commit per file. Close with the three commands they'll use most
   (/journal, /prep-session, /ingest-recordings).

## Seeding someone else's repo (the seeder's side)
Only with the recipient's knowledge. Seed in a session that has NOT loaded
the seeder's own context (a fresh session in the new folder). Include only
the recipient's own words (texts they sent, what they said on tape), facts
they stated about themselves, and agreements both people made. Never the
seeder's journal, their private material, their read of the recipient, or
third parties' opinions of the recipient. Write `SEED.md`: one line per item
with source file, date, state (sober/substances/late), consent audible yes/no.
The seeder reviews it, hands it over (AirDrop/USB/their own account), and
keeps no copy.
