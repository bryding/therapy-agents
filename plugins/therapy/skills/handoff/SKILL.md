---
name: handoff
description: Write HANDOFF.md before the owner clears context or ends a long session, so the next session resumes with zero prior context. Use when the owner says "handoff", "save context", "I'm going to clear", or at the end of a big batch of work.
---
Overwrite `HANDOFF.md` at the life-repo root (it's a baton, not history):

- **Written:** date, time, and the git HEAD.
- **START HERE:** the files to read first, in order (at most five).
- **Live state:** what's true right now, dated, 10 lines max: where things
  stand with the people who matter, what's pending, any safety context.
- **Next step:** the single most important thing, and what NOT to do.
- **Not done / not proven:** open questions to ask the owner.
- **Gotchas:** anything a fresh session would get wrong.

Facts only from the records; no new interpretation. Commit
`Handoff: <date> <one-line state>`.
