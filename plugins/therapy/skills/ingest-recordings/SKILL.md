---
name: ingest-recordings
description: Pull new voice recordings (therapy sessions, hard conversations, voice memos) from the owner's Google Drive recordings folder, transcribe them with ElevenLabs, save transcripts to docs/transcripts/, summarize each, and update the life repo. Use when the owner says "grab my recordings", "process the recordings", "I uploaded a recording", "transcribe", or at session start when Drive may have grown. Idempotent.
---
Drive folder -> rclone -> ElevenLabs Scribe -> `docs/transcripts/` ->
/summarize-session per transcript -> context updates -> commits.

ElevenLabs is the one third party that sees raw audio, and only if the owner
chose it (their CLAUDE.md says so). Never upload audio anywhere else, never
email it. Recording other people needs their knowledge; note consent in each
summary.

## Preconditions (check, don't assume)
1. `rclone listremotes` shows the remote named in `recordings_remote`
   (`therapy config get recordings_remote`, default `gdrive:Recordings`). If
   not, the owner runs `rclone config` once (type drive, name gdrive,
   read-only scope is enough). Claude can't do the browser login.
2. The ElevenLabs key file exists (`therapy config get elevenlabs_key_file`;
   one line `ELEVENLABS_API_KEY=`). Never print it or copy it into any repo.
   `therapy stt check` may 401 on a speech-to-text-only key; fine. The real
   test is a transcribe.
3. If the permission classifier blocks the command, ask the owner to allow
   `Bash(therapy:*)`. Don't route around it.

## Steps
1. `therapy ingest list`: new vs `docs/transcripts/manifest.json`. None? Stop.
2. `therapy ingest run` (background it; minutes per file). Writes diarized
   `.txt` (`S0:`, `S1:`, `[mm:ss]`) plus `.words.json`; audio stays in
   `docs/transcripts/audio/` (gitignored). Rename a transcript to a better
   slug if obvious (e.g. `_<therapist>.txt`), updating the manifest paths.
   Commit `Add transcripts ... (N recordings)`.
3. /summarize-session each. For long or multi-tape days, fan out one
   subagent per transcript; each returns its header, facts list, and
   proposed context changes, and the driver applies them.
4. Apply context changes (people, partner file, agreements, substances if
   present) from sessions only, never from journal. Update docs/index.md,
   TODO.md, HANDOFF.md if present. One commit per document.
5. Write each summary path into the manifest (`"summary": ...`). Commit.
6. Report a table (recording -> summary) and what changed in context/. Then
   give the owner your honest read if they asked for one.

## Fallbacks
- Audio on disk, not Drive: `therapy ingest local <file> --title "..." --date YYYY-MM-DD`.
- Never edit files in `docs/transcripts/`; they're input.
