# therapy-agents

An LLM-assisted therapy harness for [Claude Code](https://claude.com/claude-code).

It is not a therapist. It's a thinking partner and record-keeper that sits
alongside real therapy: it keeps a private, versioned "life repo" of your
sessions, journal, agreements and patterns, and helps you use it honestly.

What it does:

- **/journal**: near-verbatim entries plus a short, honest reflection. Flags
  entries made late at night or on substances for sober review.
- **/ingest-recordings**: Google Drive voice memos -> ElevenLabs transcription
  -> structured session summaries -> context updates.
- **/summarize-session**, **/prep-session**: session records and agendas.
- **/letter**: drafts messages to real people, with an "are you activated?"
  gate and a list of what it left out.
- **/check-in**, **/review-patterns**, **/digest-journal**, **/reminders**,
  **/import-journal** (Apple Journal), **/onboard**, **/update-harness**.
- A session-start hook that tells Claude the date and time, how long since
  your last session, journal entry and check-in, what's pending, and whether
  a harness update is available.

The design rules that matter most live in the life repo's CLAUDE.md:
honesty over agreement, the **journal-voice rule** (venting is processing,
not belief, and never becomes "facts" about other people), and the
**state/timing rule** (conclusions reached late or altered get re-examined).

## Install

```sh
git clone https://github.com/bryding/therapy-agents.git
sh therapy-agents/install.sh
therapy new-life ~/my-life --owner "Your Name"
cd ~/my-life && claude      # then: /onboard
```

`install.sh` registers this marketplace with Claude Code, installs the
`therapy` plugin at user scope, and puts a `therapy` command in `~/.local/bin`.
The plugin's hook and skills only act inside a folder containing
`.therapy-harness.json`, so it stays out of your other projects.

Optional: `brew install rclone` + `rclone config` (Drive, named `gdrive`) and an
ElevenLabs key in `~/.config/therapy-harness/elevenlabs.env` for recordings.

## Updates

Session start tells you when a newer version is published. `therapy update`
installs it; restart Claude Code.

## Privacy

This repo is public and contains no one's life. Your life repo is the opposite:
keep it local or on an encrypted private remote. It will contain things about
people who didn't agree to be written about. Audio goes to ElevenLabs only if
you set that up; nothing else leaves your machine except your normal Claude
Code traffic.

## Developing

See CLAUDE.md. Short version: edit under `plugins/therapy/`,
`sh bumpVersion.sh therapy`, commit, push.

## License

MIT.
