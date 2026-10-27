# Publishing checklist (Steam Workshop)

Do this **after** the in-game test (`docs/TESTING.md`) passes. **Workshop publication is not authorized yet (see `CLAUDE.md`).** Keep this checklist ready; do not upload until the owner explicitly asks.

## Before uploading

- [ ] **Owner go-ahead:** an explicit owner request to publish, after at least one full run to Mom without mod errors (E6 in `docs/HANDOFF.md`).

- [ ] **Permission:** Record an explicit permission or applicable redistribution license for each character design and source asset. Record the evidence in `resources/ART_LICENSE.md`.
- [ ] **mySh1_loRis:** messaged about 《克劳德的结合》, so the two projects don't clash (see `docs/IDEAS.md`).
- [ ] **Art:** all 22 forms already use their own sprites. Nine tainted forms are darker derivatives of their normal art, and some item icons are still placeholders (see `docs/ART_STATUS.md`). Either finish them or say "some placeholder art" in the description.
- [ ] **Cover:** `thumb.png` (512×512) replaced with real Claude-chan art. The current one is a placeholder Ban Hammer.
- [ ] **metadata.xml:** check that `<directory>` still matches the folder name, and that it's **this** mod's file. A wrong metadata file is a known way to upload the wrong mod.
- [ ] **Name:** pick the final Workshop title now. Renaming after release can leave the metadata and the Workshop title out of sync, and fixing it may mean re-uploading.

## Upload

1. Open `The Binding of Isaac Rebirth/tools/ModUploader/ModUploader.exe`.
2. Choose this mod folder; it reads `metadata.xml`.
3. Set **visibility to Private** for the first upload, subscribe from a second account or ask your friend, and check that it installs and runs.
4. Fill in the Workshop description (below) and pick the tags that fit, e.g. character / items / Lua, from the uploader's list.
5. Switch to **Public** only when the private test works.

## Workshop description (draft)

> **Claude-chan: Risk Control** — a parody mod with 11 AI-chan families (22 normal and tainted characters): Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM. Each one plays a community meme, such as Claude's usage limit and ban appeals, DeepSeek's rice breaks and peak hours, or GPT's model downgrades. As Claude-chan, every floor hands you a random proxy IP: the more people share it, the higher your 风控值 (risk score), and the tougher the enemies get. Find 80 meme collectibles like *Ultrathink*, *9.9 Yuan Relay*, *--dangerously-skip-permissions* and *529 Overloaded*, plus 12 trinkets and 5 pills.
>
> Character design by **ZipZipPipe** (Bilibili / Pixiv), used non-commercially with credit. DeepSeek-chan references: original OC by **上善无形**. Fan work, free, non-commercial; not affiliated with or endorsed by Anthropic or any other company.
>
> Supports EID (English for every item and character; 简体中文 / 日本語 for part of them). Requires Repentance or Repentance+. Mods don't work in Repentance+ online co-op.

## After uploading

- The uploader writes an `<id>` into `metadata.xml`. Commit it, since later updates need it.
- Post the Workshop link in the README.
