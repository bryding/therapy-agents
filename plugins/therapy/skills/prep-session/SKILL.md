---
name: prep-session
description: Prepare an agenda for an upcoming individual or couples therapy session. Use when the owner says "prep for <therapist>", "what should I bring to therapy", "session tomorrow", or the day before a session.
---
Prep for the therapist in $ARGUMENTS (default: the individual therapist in
`.therapy-harness.json` / CLAUDE.md). Output `docs/prep/YYYY-MM-DD_<therapist>.md`.

Gather, in order:
1. `context/agreements.md`: status of each active commitment. Ask for what
   you can't infer. Be blunt about what hasn't happened.
2. The last summary with this therapist, especially its suggested agenda.
3. Every journal entry since then: live threads, not a recap.
4. Anything flagged "needs sober review" and not yet reviewed.
5. Open TODO items marked for a session.

Produce (under a page; they read it in the car):
- **Since last time** (5 lines, factual).
- **Agreements check** (one line each: kept / slipped / undefined).
- **Proposed agenda**, ranked, three items max. Put the thing they're least
  likely to raise first, and say why.
- **Questions for the therapist.**
- **One thing to say out loud in the room** they've only said to this repo.

Couples prep: also what the partner has named recently (their own words from
summaries and texts only, never speculation about their inner state), and
pending letter drafts.

Commit when done (see CLAUDE.md, Git).
