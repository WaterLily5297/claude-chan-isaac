# Instructions for Claude and contributors

Read docs/HANDOFF.md first. It is the current consolidated checkpoint. docs/HANDOFF_HISTORY_2026-10-24.md preserves historical evidence and must not be treated as current acceptance.

- New code, comments, Markdown and interface text use English, as explicitly requested by the owner. Reply in the user's conversational language.
- Fetch main and inspect local status before work. Preserve all collaborator commits and uncommitted drafts. Use a focused main-based branch and PR, with no stacks. The owner permits merging the agent's own compatible fix after check.sh/CI pass when there is no blocking bug or open design decision. This is not Workshop permission.
- Run `bash tools/check.sh` before committing. Update docs/HANDOFF.md and relevant acceptance records with each material change.
- The latest owner request was installation for manual testing. Preserve that installed checkpoint during source follow-ups; do not replace files or take over game input during the owner's test. Resume agent-run engine testing only when the owner is available. Before an authorized replacement, verify a fresh allowlisted backup; preserve other mods and saves, mute agent-run tests and close the game afterward. CI/stubs, installation, historical engine evidence and current acceptance are distinct.
- Never restore DeepSeek proxy/IP/risk mechanics. Do not serialize engine entities; version and isolate player state. Preserve native weapons, size and transformation effects. Mod forms keep a fixed look: item costumes are cleared (owner, 2026-10-24), never their effects.
- Enemies represent fictional abuse mechanisms, not people or nationalities. Meme parody is not a factual allegation. No reference to Grok's July 2025 offensive content.
- No official company logos, private uploads, credentials from chat or premature Workshop release. Code is MIT; character designs/art are not. Read resources/ART_LICENSE.md and preserve credits/non-commercial conditions.
- Before each engine block, obtain fresh owner confirmation that they are away from the keyboard for a stated time window. On input interference, a missing monitor or obscured capture, stop immediately without retrying or sending keys; close only the process launched for that block and restore settings. One failed attempt per go-ahead.
- Before an authorized runtime replacement, follow the owner's E:/ba allowlist and hash-verification workflow. Keep backup contents and private paths out of public commits.
