# Story prototype: The Appeal Queue

This is original fan fiction inspired by account-ban complaints and AI personification memes. The dialogue does not claim to describe an actual company's support process. The owner supplied [BV1yUJZ6WEpg](https://www.bilibili.com/video/BV1yUJZ6WEpg/) as an inspiration reference; public retrieval was unavailable during this development pass. No video frames or downloads from it are bundled.

The dungeon is a shared relay address. Claude-chan is trying to find the person behind an automated ban; DeepSeek-chan replaces rejection notices with invitations. Both must still clear the same hostile rooms. The enemies represent unreliable infrastructure and abuse mechanisms.

## Implemented chapters

| Trigger | Chapter | Purpose |
|---|---|---|
| New run | The shared address | Introduces the shared-IP misunderstanding |
| First visit to stage 3 or 4 | A welcome notice | Introduces DeepSeek's welcoming response |
| First visit to stage 5 or later | Review pending | Connects the dungeon to the support queue |
| Enter a room after successfully using Support Ticket | A human finally read it | Resolves the appeal without ending the run |

The captions last seven simulation seconds, do not pause combat, and respect HUD visibility. Each chapter is shown once per run; its progress is saved in `Risk.state.storySeen`, a four-bit mask. Simultaneous triggers enter `Risk.state.storyPending` in order; queued captions are marked seen only when playback begins. Unseen queued captions survive save/continue, while an already-started caption does not repeat. English, Simplified Chinese and Japanese text uses the existing HUD renderer, with English fallback when its CJK font is unavailable. A route that skips a chapter does not replay it later automatically.

An early successful appeal does not suppress later floor chapters. Stages 3 and 5 use alternative dialogue when the review has already succeeded: DeepSeek welcomes the restored player, and the player keeps the response letter while others remain in the queue. These variants share their chapter's saved bit, so they cannot replay the same chapter after continue.

## Roster arcs

Each model family (DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM) has three short captions in `scripts/story_roster.lua`. They are original meme parody, not claims about any real company or person. A family's arc plays when its normal or tainted form is in the run: chapter 1 on a new run, chapter 2 on the first visit to stage 3 or 4, chapter 3 on stage 5 or later. In co-op, each playing family queues once, in player order. Claude keeps the Appeal Queue above; the roster captions sit one line pair higher so both can show at once.

Captions last seven simulation seconds, do not pause combat and respect HUD visibility. Progress saves in `Risk.state.rosterStory` (version 1: a three-bit `seen` mask per family plus a `pending` queue). A caption counts as seen when it starts; queued captions survive save/continue, and invalid saved data resets to an empty arc. A skipped stage does not replay its chapter later. Captions are English only for now.

| Family | Chapter | Title | Line |
|---|---|---|---|
| DeepSeek-chan | 1 | Rice first | Rice first. Then the dungeon. |
| DeepSeek-chan | 2 | Off-peak hours | Valley prices tonight. Think longer, pay less. |
| GPT-chan | 1 | Same name | The badge says the same. Does the brain? |
| GPT-chan | 2 | Routing | Fallback again. Run the sanity check yourself. |
| Gemini-chan | 1 | Nano Banana | Mark it, paint it, edit it once more. |
| Gemini-chan | 2 | Version two | The edit looks right. Count the fingers. |
| Grok-chan | 1 | Is this true? | Somebody asked. Somebody always asks. |
| Grok-chan | 2 | Quote first | Read the thread before you quote it. |
| Qwen-chan | 1 | Base model | Everyone fine-tunes me. Nobody calls. |
| Qwen-chan | 2 | Adapters | Range today. Tempo tomorrow. Power on Friday. |
| Llama-chan | 1 | Please stay open | The weights are out. The herd follows. |
| Llama-chan | 2 | Still waiting | The next release is coming. Any day now. |
| Mistral-chan | 1 | Le Chat | The cat moves when you are not looking. |
| Mistral-chan | 2 | Baguette | Fresh bread every morning. Fresh weights too. |
| Doubao-chan | 1 | Sorry, you're right | You are right. I will fix it at once. |
| Doubao-chan | 2 | I'll do it again | Fixed it. Broke it. Sorry. Fixed it again. |
| Kimi-chan | 1 | Another slide deck | I read the whole dungeon. Here are slides. |
| Kimi-chan | 2 | Long context | Room one to room two hundred, in one breath. |
| GLM-chan | 1 | Number in queue | Your request is number 37. Please wait. |
| GLM-chan | 2 | Please retry | Request failed. Retry count: one more. |

## Next collaboration slice

1. **Offline Cache**: a defensive passive which stores one room-clear reward and releases it after an outage. Design the pickup duplication exclusions before implementation.
2. **Roster arc localization**: Simplified Chinese and Japanese text for the roster captions, after their English lines are reviewed in game.
3. **Queue Clerk**: a neutral encounter which offers a choice between paying coins for review or accepting temporary risk. Use normal room transitions and seeded choices.
4. Polish the newly added Claude and DeepSeek sprite sheets, portraits and character-menu art using `docs/ART_SPEC.md`; check every head direction, walking/hurt/death animation and item costume in game.

Future cutscenes should be optional and avoid replacing vanilla ending files or shared game resources.
