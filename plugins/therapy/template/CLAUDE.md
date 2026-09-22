# {{OWNER}}'s life repo

Personal growth / therapy documentation for {{OWNER}}. The harness plugin
(therapy-agents) supplies the skills, the `therapy` CLI, and the core rules,
which its session-start hook injects every session so fixes reach everyone.
This file holds only what is specific to {{OWNER}}.

## Mine
(How {{OWNER}} wants Claude to be: blunt or gentle by default, what to do when
they say they're hurting, words to avoid, anything off limits. /onboard fills
this in.)

## Core context (loaded every session)

- @context/me.md
- @context/people.md
- @context/patterns.md
- @context/agreements.md
- @context/safety.md

On demand, not loaded by default: `context/journal-digest.md`,
`context/timeline.md`, `docs/index.md`, `TODO.md`, any partner or archive file.
Size caps: me 40 lines, people 50, patterns 40, agreements 50, safety 15.
The hook warns when a file is over; run /rollover.

## Layout

- `context/` current facts, kept short; `context/archive/` rolled-over history
- `docs/sessions/` dated session summaries (`YYYY-MM-DD_source.md`)
- `docs/journal/` journal entries and check-ins (`YYYY-MM-DD.md`)
- `docs/letters/` drafts and sent messages to real people
- `docs/prep/` session prep
- `docs/transcripts/` raw transcripts (input only; never edit). Audio stays local.
