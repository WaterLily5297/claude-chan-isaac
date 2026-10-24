# Claude-chan: Risk Control

A parody mod for **The Binding of Isaac: Repentance / Repentance+**.

**Expansion in development:** [22-form community-meme gameplay](docs/CHARACTER_GAMEPLAY.md) and [50 additional collectible designs](docs/EXPANSION_DESIGN.md). Summary Stapler is the first locally implemented item: a four-charge active that compresses nearby ordinary hostile bullets into one slow native tear. It keeps normal tear effects, character limits and forks; empty use preserves charge and Car Battery does not repeat it. Thirteen forms and eighteen collectibles are currently registered. The remaining expansion designs are not implemented, and current engine acceptance remains pending.

**Experimental roster candidate:** eleven model families, eleven ZipZipPipe-based normal portraits, two darker tainted portraits, nine additional playable normal characters and in-game dossiers. Hold MAP in a cleared room to view the current character's portrait and instructions. See [the roster and mechanics](docs/MODEL_ROSTER.md), [pending engine checks](docs/TESTING.md), and [art terms](resources/ART_LICENSE.md). All thirteen gameplay skins now follow the selected portrait identities; animation polish and engine acceptance remain pending; this is not a Workshop release.

Every floor hands you a random proxy IP. The more people share it, the higher your **risk score** (风控值). The higher the risk, the tougher the enemies get, and killed enemies start coming back as "new accounts".

> Fan work. Not affiliated with or endorsed by Anthropic. Character illustrations are credited fan-art derivatives; see the separate art terms.

[中文](#中文) · [日本語](#日本語)

## Features (v0.5-dev)

| | |
|---|---|
| **Claude-chan** (playable) | Range +1.5 (long context window), Shot Speed +0.2, Speed −0.1, 2 red + 1 soul heart, orange tears. Starts with **Ban Hammer** as a pocket item. **Usage limit:** every tear fills a usage meter that drains slowly; when it's full, her tears deal 40% damage for 5 seconds. **Account age (账号满月):** +0.2 damage for every floor reached without being Suspended (max +1.6); a suspension resets it ("Banned again" / 又封了). *Custom orange-haired sprite atlas and portraits; animation polish is in progress.* |
| **Tainted Claude-chan** (裏 / playable) | **Weekly limit (周限额):** instead of the usage meter, 220 tears per floor; past it, tears deal 25% until the next floor. Damage ×1.25, Range +1.5, Shot Speed +0.2. Starts with pocket **Banked Reset**, which refills the quota. Redrawn crimson-haired skin with a black-and-gold dress. |
| **DeepSeek-chan** (playable) | **Direct connection (直连):** she needs no proxy, so in a DeepSeek-only run there is no IP, no risk and no risk-based difficulty. **Deep Think (深度思考):** not shooting builds up to 5 s of thought; the next tear deals up to ×2 and the HUD reads "Thought for N s". **Server busy (服务器繁忙):** the more enemies in the room, the more often a tear doesn't go out (3% per enemy, max 25%). **Slacking off (摸鱼):** standing still for 5 s in a cleared room recharges Lunch Break by one. Starts with pocket **Lunch Break**; damage ×0.9, blue tears. |
| **Tainted DeepSeek-chan** (裏 / playable) | Direct connection too. **Wenfeng / Wengu:** combat alternates 12 s of Valley and 12 s of Peak. Paid tear volleys fork into two extra tears at ±12° (50% damage) for 2 Compute in Valley or 4 in Peak; Valley recovers Compute while you hold fire. Tap DROP to switch Forks On / Saving. No random shot deletion. Damage ×0.8. Redrawn deep-teal and white maid skin. |
| **Lunch Break** (DeepSeek-chan's pocket active, 6 charges) | "飯食ってくる / 去吃饭了": heals one red heart and slows every enemy for 3 s, but you stop shooting for 3 s. |
| **The Appeal Queue** | Four short, localised story captions during a run; chapter progress survives save/continue. |
| **Risk score** | 0–100. At **90+ your account is Suspended**: damage ×0.75 until risk drops. Each floor rolls an IP: crowded relay IPs add more risk. Getting hit +1, clearing a room without a hit −1. Shown at the bottom-left of the HUD. |
| **Enemy scaling** | Enemy HP ×1 at risk 0, up to ×3 at risk 100. |
| **Hydra accounts** | From risk 40 on, a killed enemy may respawn once (tinted red), from 10% up to 50%. |
| **Relay Slime** (enemy) | A shared proxy. Appears in 25% of uncleared rooms once risk ≥ 30; splits in two on death, twice, so one slime becomes up to seven. *(Placeholder: a green-tinted vanilla Clotty.)* |
| **Agentic** (transformation) | Hold any 3 of Ultrathink, Compact, Vibe Coding, Subagent Swarm, --dangerously-skip-permissions, All Tests Passing: flight, fire delay ×0.8, damage +0.5. |
| **Ban Hammer** (active, 4 charges) | Bans every non-boss enemy in the room; bosses take 60 damage. Banned enemies never respawn. But 20% of bans are **misbans** of innocent developers, +3 risk each ("appeal pending"). |
| **Residential IP** (passive) | Risk −30 on pickup, and every later risk increase is halved. |
| **Compact** (active, 3 charges) | "Compacting conversation...": removes all enemy projectiles, confuses every enemy for 3 s. Costs Claude-chan 50 usage (the "compacting ate my 5-hour limit" meme). |
| **You're Absolutely Right!** (passive, angel pool) | Any enemy that hurts you instantly agrees with you and is charmed for 5 s. |
| **9.9 Yuan Relay** (passive, devil pool) | Damage ×1.5, but each room has a 30% chance of a secret model swap (×0.5 instead). Risk +15 on pickup. Based on the Chinese "cheap relay quietly swaps the model" (掺水) complaints. |
| **Ultrathink** (active, 5 s recharge) | Each use in the same room thinks harder: think +1 / megathink +2 / ultrathink +3.1999 damage (after the oddly specific 31,999-token budget). 15% of the time: "Thought for 0s", nothing happens. |
| **1M Context** (passive) | Range +5, but context rot: tears lose damage the longer they fly, down to 30%. |
| **Silent Update** (passive) | Every floor, damage is quietly rescaled to ×0.8–×1.3. The only message you ever get: "Changelog: no changes". Based on the 降智 ("did they nerf it?") complaints. |
| **--dangerously-skip-permissions** (passive, devil pool) | Locked doors and locked chests open by themselves. But each room has a 10% chance of `rm -rf`: every pickup on the floor is deleted (pedestals are safe). |
| **All Tests Passing** (active, 6 charges) | Reward hacking: the room counts as cleared and every door opens, but the enemies are still there. |
| **Hardcoded Output** (trinket) | Every tear deals exactly 3.5 damage, "the expected output", however strong or weak you are. |
| **Thinking Cleared** (trinket) | Damage +1, but each new room your active item loses 1 charge. Based on the reported cache bug that wiped the thinking every turn. |
| **Vibe Coding** (passive) | Every tear gets a random effect; 5% of tears are bugs that fly backwards; each new floor the API bill takes 25% of your coins, unless you **made no mistakes** (no hit) on the floor you just left. |
| **Banked Reset** (active, 12 charges) | A rate-limit reset you can save for later: risk −25, and clears Claude-chan's usage meter (ends a limit early). |
| **Subagent Swarm** (passive, devil pool) | Every tear spawns 2 parallel subagent tears at ±15° (50% damage). Claude-chan's tears cost double usage. |
| **Cat-girl Mode** (pill) | For the rest of the room, tears fire twice as fast at 60% damage. Based on DeepSeek-chan often being asked to answer as a cat girl. |
| **Brb, Getting Food** (pill) | Heals one red heart, but you stop shooting for 3 s. Based on DeepSeek's famous "飯食ってくる" reply. |
| **Welcome Notice** (trinket) | From fan lore where DeepSeek-chan swaps Claude-chan's ban card for a welcome message: Ban Hammer turns regular enemies into permanent allies instead of banning them. |
| **Status Page** (trinket) | Every risk increase is 1 smaller, but the HUD hides your real risk and only ever says "all systems operational". |
| **The Constitution** (passive, angel pool) | Claude's constitution ranks safety, ethics, guidelines, then helpfulness: +1 soul heart, the first hit on each floor is refused ("I can't help with that"), damage ×0.9 (helpfulness is last), speed −0.1 (it's a long document). |
| **Appeal Form** (trinket) | Used up the moment risk reaches 90; your risk drops back to 50 instead of getting suspended. |
| **Opus Mode** (passive, shop) | "More expensive than gold": damage ×1.8, but every 10 tears cost 1 coin. At 0 coins you fall back to a cheaper model: damage ×0.6. |
| **529 Overloaded** (trinket) | Every 20 s in a fight, everything goes down for 2 s: all enemies freeze, and you're left **coding manually**: you can still shoot, at 50% damage. "Status page: all systems operational." |

Supports [External Item Descriptions](https://steamcommunity.com/sharedfiles/filedetails/?id=836319872) in English, Simplified Chinese and Japanese.

## New in v0.4-dev

- **Support Ticket** / **人工复核工单** / **サポートチケット**: six-charge shop active; pay 3 coins to reduce risk by 20. Failed uses keep the charge, and Car Battery does not bill twice.
- **DeepSeek-chan** / **DeepSeek娘** / **DeepSeekちゃん**: a welcoming counterpart to Claude-chan (redesigned in v0.5-dev: see the table above).
- **The Appeal Queue** / **申诉队列** / **異議申し立ての列**: four optional-to-read captions in English, Chinese and Japanese. This original fan story does not replace vanilla cutscenes.
- Both characters now have custom generated sprite atlases, portraits, name images and character-selection assets. These are a first art pass, with animation and costume-interaction checks still required.

See [docs/HANDOFF.md](docs/HANDOFF.md) for exact validation limits and [docs/STORY.md](docs/STORY.md) for the next collaboration slice.

## Credits

- **Claude-chan character design:** [ZipZipPipe](https://space.bilibili.com/4168597) ([Pixiv《AI娘化》](https://www.pixiv.net/artworks/148186519), [《大AI和小AI们》](https://www.bilibili.com/video/BV1tE9XBbErS/)). Used non-commercially with credit, per the author's terms.

- **DeepSeek-chan design references:** 上善无形 and ZipZipPipe.
- **32x32 item icon set:** RORICO444, PR #2. Character bitmaps in this development pass were generated with imagegen; see [art provenance](docs/ART_GENERATION.md).

## Install for development

1. Copy (or symlink) this folder to `Steam/steamapps/common/The Binding of Isaac Rebirth/mods/claude-chan-isaac/`.
2. Turn on the debug console: set `EnableDebugConsole=1` in `options.ini` (`Documents/My Games/Binding of Isaac Repentance+/`).
3. Start a run, press `~` and try:
   - `giveitem Ban Hammer` / `giveitem Residential IP`
   - `luamod claude-chan-isaac` to reload the Lua after editing

## Tests (no game needed)

Smoke tests run the mod against a stubbed Isaac API with plain Lua 5.3+:

```
lua tests/smoke_test.lua .
lua tests/hud_text_test.lua .
lua tests/eid_test.lua .
```

They catch crashes and logic errors, not how the game feels; see [docs/TESTING.md](docs/TESTING.md) for the in-game checklist.

`bash tools/check.sh` runs all of them plus syntax, XML and sprite-path checks. GitHub Actions runs the same script on every push and pull request.

## Contributing

Friends are welcome to work on this. Read [CONTRIBUTING.md](CONTRIBUTING.md) (in Chinese) or [docs/HANDOFF.md](docs/HANDOFF.md) (in English): work on a branch, open a pull request, and keep player-facing text in English, Chinese and Japanese.

## Project layout

```
main.lua                  entry point, loads every module
scripts/constants.lua     item IDs, risk tiers, thresholds
scripts/risk.lua          risk score, IP roll, save/load, HUD
scripts/enemy_scaling.lua enemy HP scaling
scripts/hydra.lua         "new account" respawns
scripts/items/            one file per item
scripts/characters/       playable characters
scripts/enemies/          custom enemies
scripts/eid.lua           EID descriptions (en / zh / ja)
content/                  items.xml, itempools.xml, players.xml, pocketitems.xml
docs/ART_SPEC.md          sprite checklist for the pixel artist
resources/gfx/            sprites
tools/make_placeholders.py  regenerates the placeholder item sprites
tools/check.sh            pre-commit checks (same as CI)
```

## Roadmap

- [x] **Claude-chan** as a playable character (stats, pocket Ban Hammer, usage limit).
- [ ] Claude-chan sprites: body, hair costume, portraits, name image. See [docs/ART_SPEC.md](docs/ART_SPEC.md).
- [ ] Custom enemies themed on abuse mechanisms, not people:
  - [x] Relay Slime (shared proxy, splits on death), placeholder art
  - Distillation Bot (copies your tears and shoots them back)
  - Timezone Ghost (invisible until revealed)
- [x] **Misban** mechanic: 20% of Ban Hammer bans hit innocent developers and raise risk.
- [ ] Other AI-musume characters as bosses, familiars or unlockables.
- [ ] More risk sources and counters (timezone spoofer, native card…), plus a devil-deal-style "risk for reward" trade.
- [~] CJK HUD: HUD text follows the game language (中文 / 日本語) when a CJK font loads; otherwise English. The vanilla font path `font/cjk/lanapixel.fnt` is unconfirmed; check in game.

## License

Code: [MIT](LICENSE). Character designs and character art are **not** MIT: credit the original designers, non-commercial only. See [resources/ART_LICENSE.md](resources/ART_LICENSE.md). This mod must stay free.

---

## 中文

《以撒的结合：忏悔 / 忏悔+》的恶搞MOD。每一层会随机分配一个代理IP，共享人数越多，**风控值**越高；风控值越高，敌人越强，被击杀的敌人还会以"新账号"复活。

- **Claude娘**（可操作角色）：射程+1.5（长上下文）、弹速+0.2、移速−0.1，初始口袋道具为封号锤。**用量限制**：每发眼泪都会增加用量，用满后5秒内眼泪伤害降为40%。**账号满月**：每层未被封禁伤害+0.2（最多+1.6），被封禁就清零（又封了）。角色形象设计：[ZipZipPipe](https://space.bilibili.com/4168597)（署名・非商用）。
- **里Claude娘**（可操作角色）：**周限额**——没有用量条，每层只能射220发，超过后到下一层前伤害降为25%；伤害×1.25，初始口袋道具为储存的重置（可恢复周限额）。
- **DeepSeek娘**（可操作角色）：**直连，无需代理**——单人时没有IP、没有风控，也没有风控带来的难度。**深度思考**：不射击时积累思考（最多5秒），下一发伤害最高×2，显示"已深度思考（用时N秒）"。**服务器繁忙**：敌人越多，眼泪越常发不出去（每个敌人3%，最高25%）。**摸鱼**：在已清理的房间站着不动5秒，去吃饭了充能+1。初始口袋道具：去吃饭了。设计：上善无形 / ZipZipPipe。
- **里DeepSeek娘**（可操作角色）：同样直连。**开源**：每发眼泪都会被fork出2发±12°的眼泪（50%伤害）；服务器更容易繁忙（最高40%）；伤害×0.8。
- **去吃饭了**（DeepSeek娘的口袋主动，6充能）：回复1颗红心，所有敌人减速3秒，但3秒内无法射击。
- **封号锤**（主动，4充能）：封禁房间内所有非Boss敌人，Boss受到60点伤害，被封禁的敌人不会复活。
- **中转站史莱姆**（敌人）：风控值≥30后，25%的未清理房间会出现；死亡时分裂两次，一只最多变成七只。（暂用绿色的原版Clotty代替）
- **Agentic变身**：集齐Ultrathink、压缩上下文、氛围编程、子代理大军、--dangerously-skip-permissions、测试全部通过中的任意3个：获得飞行、射速提升、伤害+0.5。
- **住宅IP**（被动）：拾取时风控值−30，之后风控值增加量减半。
- **压缩上下文**（主动，3充能）：清除敌方弹幕，所有敌人混乱3秒；Claude娘使用时消耗50用量。
- **您说得完全正确！**（被动，天使房）：伤害你的敌人会被魅惑5秒。
- **9.9元中转**（被动，恶魔房）：伤害×1.5，但每个房间有30%概率被偷偷换成小模型（伤害×0.5）；拾取时风控值+15。
- **Ultrathink**（主动，5秒充能）：同一房间内每次使用伤害依次+1 / +2 / +3.1999；15%概率"思考了0秒"，什么都没发生。
- **1M上下文**（被动）：射程+5，但眼泪飞得越久伤害越低（最低30%）。
- **静默更新**（被动）：每层伤害被悄悄调整为×0.8～×1.3，提示永远只有"更新日志：无变化"。
- **--dangerously-skip-permissions**（被动，恶魔房）：上锁的门和箱子自动打开；但每个房间有10%概率执行 `rm -rf`，删除所有掉落物（道具底座除外）。
- **测试全部通过**（主动，6充能）：房间视为已清理、所有门打开，但敌人还在。
- **硬编码输出**（饰品）：每发眼泪固定造成3.5点伤害。
- **思考被清空**（饰品）：伤害+1，但每进入新房间主动道具失去1格充能。
- **氛围编程**（被动）：每发眼泪随机获得一种效果；5%的眼泪是会往回飞的bug；每层API账单扣掉25%硬币——但上一层一次都没受伤（Make no mistakes）就免单。
- **储存的重置**（主动，12充能）：风控值−25，Claude娘用量清零。
- **子代理大军**（被动，恶魔房）：每发眼泪额外生成2发±15°的子代理眼泪（50%伤害）；Claude娘用量消耗翻倍。
- **猫娘模式**（药丸）：本房间内射速翻倍，伤害降为60%。
- **去吃饭了**（药丸）：回复一颗红心，但3秒内无法射击。
- **欢迎通知**（饰品）：DeepSeek娘把封号卡换成了欢迎词——封号锤会让普通敌人永久成为同伴。
- **状态页**（饰品）：每次风控值增加量−1，但界面永远只显示"所有系统运行正常"。
- **宪法**（被动，天使房）：+1魂心；每层第一次受到的伤害会被拒绝；伤害×0.9（有用性排最后）；移速−0.1（文档太长）。
- **申诉表**（饰品）：风控值达到90（封禁：伤害×0.75）时自动消耗，风控值降回50。
- **Opus模式**（被动，商店）：伤害×1.8，但每10发眼泪消耗1枚硬币；没钱时退回便宜模型，伤害×0.6。
- **529 Overloaded**（饰品）：战斗中每20秒全部宕机2秒：所有敌人冻结，你只能手写代码——还能射击，但伤害50%。

安装方法：把本文件夹放进 `mods/` 目录，在 `options.ini` 中设置 `EnableDebugConsole=1`，游戏中按 `~` 输入 `giveitem Ban Hammer` 测试。

**想一起开发？** 测试、画图、出点子、写代码都欢迎，请看 [CONTRIBUTING.md](CONTRIBUTING.md)。

本作为同人恶搞作品，与 Anthropic 无关。

## 日本語

『The Binding of Isaac: Repentance / Repentance+』のパロディMODです。フロアごとにランダムなプロキシIPが割り当てられ、共有人数が多いほど**リスク値（风控值）**が上がります。リスク値が高いほど敵が強くなり、倒した敵が「新アカウント」として復活するようになります。

- **Claudeちゃん**（プレイアブル）：射程+1.5（ロングコンテキスト）、弾速+0.2、移動速度−0.1、初期ポケットアイテムはBANハンマー。**利用上限**：涙を撃つたびに使用量が溜まり、満タンになると5秒間涙のダメージが40%に下がる。**アカウント年齢**：停止されずに進んだフロアごとにダメージ+0.2（最大+1.6）、停止されるとリセット（又封了）。キャラクターデザイン：[ZipZipPipe](https://space.bilibili.com/4168597)（クレジット表記・非営利）。
- **裏Claudeちゃん**（プレイアブル）：**週間上限（周限额）**。使用量メーターの代わりに1フロア220発まで、超えると次のフロアまでダメージ25%。ダメージ×1.25、初期ポケットはバンク済みリセット（上限を回復）。
- **DeepSeekちゃん**（プレイアブル）：**直結・プロキシ不要**。1人プレイではIPも風控値も、それによる難易度上昇もない。**深度思考**：撃たずにいると最大5秒分の思考がたまり、次の一発が最大2倍。**サーバー混雑**：敵が多いほど涙が出ないことがある（敵1体につき3%、最大25%）。**サボり（摸鱼）**：クリア済みの部屋で5秒じっとしていると飯食ってくるのチャージ+1。初期ポケット：飯食ってくる。デザイン：上善无形 / ZipZipPipe。
- **裏DeepSeekちゃん**（プレイアブル）：こちらも直結。**オープンソース**：涙が±12°に2発フォークされる（ダメージ50%）。サーバー混雑が起きやすい（最大40%）。ダメージ×0.8。
- **飯食ってくる**（DeepSeekちゃんのポケットアクティブ、6チャージ）：赤ハート1つ回復、すべての敵を3秒スロウ。ただし3秒間撃てない。
- **BANハンマー**（アクティブ、4チャージ）：部屋内のボス以外の敵をすべてBAN。ボスには60ダメージ。BANされた敵は復活しない。
- **中継スライム**（敵）：リスク値30以上になると、未クリアの部屋の25%に出現。倒すと2回分裂し、1体が最大7体に。（仮：緑色のバニラのClotty）
- **Agentic変身**：Ultrathink、コンパクト、バイブコーディング、サブエージェント軍団、--dangerously-skip-permissions、テスト全件パスのうち3つを持つと変身：飛行、連射速度アップ、ダメージ+0.5。
- **住宅IP**（パッシブ）：取得時にリスク値−30、以降のリスク値の上昇が半分になる。
- **コンパクト**（アクティブ、3チャージ）：敵の弾を消し、すべての敵を3秒間混乱させる。Claudeちゃんが使うと使用量+50。
- **おっしゃる通りです！**（パッシブ、天使部屋）：自分にダメージを与えた敵を5秒間魅了する。
- **9.9元の中継**（パッシブ、悪魔部屋）：ダメージ×1.5、ただし部屋ごとに30%の確率でこっそり小さいモデルに差し替え（ダメージ×0.5）。取得時にリスク値+15。
- **Ultrathink**（アクティブ、5秒でチャージ）：同じ部屋で使うたびにダメージ+1 / +2 / +3.1999。15%の確率で「0秒考えた」だけで何も起きない。
- **1Mコンテキスト**（パッシブ）：射程+5、ただし涙は飛ぶほどダメージが下がる（最低30%）。
- **サイレントアップデート**（パッシブ）：フロアごとにダメージがこっそり×0.8～×1.3に変わる。表示は常に「更新履歴：変更なし」だけ。
- **--dangerously-skip-permissions**（パッシブ、悪魔部屋）：鍵付きの扉と宝箱が勝手に開く。ただし部屋ごとに10%の確率で `rm -rf` が走り、落ちているアイテムがすべて消える（台座は無事）。
- **テスト全件パス**（アクティブ、6チャージ）：部屋がクリア扱いになり扉が開くが、敵はまだいる。
- **ハードコード出力**（トリンケット）：涙のダメージが常に3.5で固定。
- **思考クリア**（トリンケット）：ダメージ+1。ただし新しい部屋に入るたびにアクティブアイテムのチャージが1減る。
- **バイブコーディング**（パッシブ）：涙にランダムな効果が付く。5%は逆方向に飛ぶバグ。フロアごとにAPI請求でコインの25%を失う。ただし直前のフロアで無傷なら（Make no mistakes）免除。
- **バンク済みリセット**（アクティブ、12チャージ）：リスク値−25、Claudeちゃんの使用量をリセット。
- **サブエージェント軍団**（パッシブ、悪魔部屋）：涙を撃つたびに±15°にサブエージェントの涙が2発（ダメージ50%）。Claudeちゃんは使用量2倍。
- **猫娘モード**（薬）：その部屋の間、連射速度2倍・ダメージ60%。
- **飯食ってくる**（薬）：赤ハート1つ回復。ただし3秒間涙を撃てない。
- **ようこそ通知**（トリンケット）：DeepSeek娘がBANカードを歓迎メッセージにすり替えた。BANハンマーで通常の敵が永久に仲間になる。
- **ステータスページ**（トリンケット）：リスク値の上昇が毎回1減る。ただしHUDは本当の値を隠し「全システム正常」としか表示しない。
- **憲法**（パッシブ、天使部屋）：ソウルハート+1。各フロアで最初のダメージを拒否。ダメージ×0.9（有用性は最後）、移動速度−0.1（長い文書）。
- **異議申し立てフォーム**（トリンケット）：リスク値が90（停止：ダメージ×0.75）に達すると消費され、リスク値が50に戻る。
- **Opusモード**（パッシブ、ショップ）：ダメージ×1.8、ただし涙10発ごとにコイン1枚。コイン0だと安いモデルに切り替わりダメージ×0.6。
- **529 Overloaded**（トリンケット）：戦闘中20秒ごとに2秒間すべてがダウン。敵は凍結し、自分は手でコードを書く：涙は撃てるがダメージ50%。

導入方法：このフォルダを `mods/` に置き、`options.ini` で `EnableDebugConsole=1` にして、ゲーム中に `~` で `giveitem Ban Hammer` を入力するとテストできます。

**開発に参加したい方へ：** テスト・ドット絵・アイデア・コード、どれも歓迎です。[CONTRIBUTING.md](CONTRIBUTING.md)（中国語）と [docs/HANDOFF.md](docs/HANDOFF.md)（英語）をご覧ください。

ファンによるパロディ作品で、Anthropicとは関係ありません。
