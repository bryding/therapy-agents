# therapy-agents

Public Claude Code plugin marketplace for the therapy harness. One plugin,
`therapy`. Each user's actual material lives in their own private "life repo";
this repo must never contain anyone's life.

## Layout

```
.claude-plugin/marketplace.json   marketplace; one entry per plugin, with version
plugins/therapy/
  .claude-plugin/plugin.json      plugin manifest (name + version)
  skills/<skill>/SKILL.md         the skills (frontmatter: name + description)
  hooks/hooks.json, session-start.sh   SessionStart hook; silent outside a life repo;
                                  injects rules/core.md every session
  rules/core.md                   the load-bearing rules (safety, honesty, journal voice,
                                  state/timing, other people, privacy); bump minor on change
  bin/therapy                     the CLI (install.sh puts a shim in ~/.local/bin)
  lib/*.py, new-life.sh           ingest, ElevenLabs STT, journal import, config, scaffolder
  template/                       what `therapy new-life` copies into a new life repo
bumpVersion.sh                    ONLY sanctioned way to change a version; --check audits
install.sh                        per-machine install/update (--local for a dev checkout)
.github/workflows/validate.yml    versions, bump-on-change, manifests, links, privacy scan
```

## Publish workflow

Installed plugins are served from a cache copy under
`~/.claude/plugins/cache/therapy-agents/therapy/<version>/`, refreshed only on
a version change.

1. Edit under `plugins/therapy/`.
2. `sh bumpVersion.sh therapy [patch|minor|major]`.
3. Commit and push. CI must pass.
4. `therapy update` on each machine; restart sessions. Other users see
   "update available" at their next session start (checked once a day).

Forgetting step 2 is the classic failure: nothing publishes, no error.

## Rules for content here

- Generic only. No names, dates, quotes, or facts from anyone's life, not
  even as examples. Use "the owner", "the partner", "<therapist>".
- Behavior that is personal belongs in the life repo's CLAUDE.md or context/,
  or in a repo-local skill there.
- Skills must work for someone who isn't in a relationship, doesn't record
  sessions, and doesn't use Apple Journal: optional features degrade quietly.
- The load-bearing rules live in rules/core.md and reach every life repo on
  update (the hook prints them). The template CLAUDE.md holds only the
  owner's own section. Change core rules deliberately, bump minor.
- Privacy gate: `git config core.hooksPath .githooks` once per checkout; the
  pre-commit hook greps staged changes against ~/.config/therapy-harness/denylist
  (names of real people, one per line; never committed). CI is the backstop.
- Maintainer workflow: .claude/skills/publish-harness (repo-local, not shipped).
- Life repos keep what they already have when the template changes; the
  template only seeds new repos. Note template changes in the commit message
  so existing users can port them by hand if they want.
