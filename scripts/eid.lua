-- Descriptions for External Item Descriptions (EID), if the player has it installed.

local Constants = include("scripts.constants")

local Eid = {}

local descriptions = {
    [Constants.Item.SUMMARY_STAPLER] = {
        en_us = { "Summary Stapler", "4 room charges#Absorbs up to 12 ordinary hostile bullets within 120 units#Fires one slow tear: damage x(1 + bullets / 4), up to x4 before other modifiers#Uses normal tear effects, character limits and forks#Empty use keeps charge; Car Battery does not repeat#Does not replace your weapon or reset usage" },
    },
    [Constants.Item.LUNCH_BREAK] = {
        en_us = { "Lunch Break", "Heals 1 red heart#All enemies are slowed for 3 seconds#Shooting input is blocked for 3 seconds; movement stays available#Cannot reuse during a food break#Car Battery does not repeat this item" },
        zh_cn = { "去吃饭了", "回复1颗红心#所有敌人减速3秒#3秒内无法射击" },
        ja_jp = { "飯食ってくる", "赤ハート1つ回復#すべての敵を3秒間スロウ#3秒間涙を撃てない" },
    },
    [Constants.Item.SUPPORT_TICKET] = {
        en_us = { "Support Ticket", "Costs 3 coins: risk -20#6 room charges#No coins or no risk: keeps the charge#Car Battery does not bill twice" },
        zh_cn = { "人工复核工单", "支付3枚硬币：风控值-20#6格充能#硬币不足或风控为零时不消耗充能#车载电池不会重复扣费" },
        ja_jp = { "サポートチケット", "コイン3枚でリスク値-20#6チャージ#コイン不足・リスク0なら消費しない#カーバッテリーで二重請求しない" },
    },
    [Constants.Item.BAN_HAMMER] = {
        en_us = { "Ban Hammer", "Bans every non-boss enemy in the room#Bosses take 60 damage#Banned enemies never respawn as new accounts#20% of bans are misbans of innocent developers: +3 risk each" },
        zh_cn = { "封号锤", "封禁房间内所有非Boss敌人#Boss受到60点伤害#被封禁的敌人不会以新账号复活#20%是误封的无辜开发者：每次风控值+3" },
        ja_jp = { "BANハンマー", "部屋内のボス以外の敵をすべてBAN#ボスには60ダメージ#BANされた敵は新アカウントとして復活しない#20%は無実の開発者の誤BAN：1件ごとにリスク値+3" },
    },
    [Constants.Item.RESIDENTIAL_IP] = {
        en_us = { "Residential IP", "Risk -30 on pickup#All risk increases are halved" },
        zh_cn = { "住宅IP", "拾取时风控值-30#之后风控值的增加量减半" },
        ja_jp = { "住宅IP", "取得時にリスク値-30#以降のリスク値の上昇が半分になる" },
    },
    [Constants.Item.COMPACT] = {
        en_us = { "Compact", "Removes all enemy projectiles#Confuses all enemies for 3 seconds#Claude-chan: costs 50 usage" },
        zh_cn = { "压缩上下文", "清除房间内所有敌方弹幕#所有敌人混乱3秒#Claude娘使用时消耗50用量" },
        ja_jp = { "コンパクト", "敵の弾をすべて消す#すべての敵を3秒間混乱させる#Claudeちゃんが使うと使用量+50" },
    },
    [Constants.Item.ABSOLUTELY_RIGHT] = {
        en_us = { "You're Absolutely Right!", "Enemies that hurt you are charmed for 5 seconds#You still take the damage" },
        zh_cn = { "您说得完全正确！", "伤害你的敌人会被魅惑5秒#你仍然会受到伤害" },
        ja_jp = { "おっしゃる通りです！", "自分にダメージを与えた敵を5秒間魅了する#ダメージは受ける" },
    },
    [Constants.Item.CHEAP_RELAY] = {
        en_us = { "9.9 Yuan Relay", "x1.5 damage#Each room: 30% chance of a secret model swap (x0.5 damage instead)#Risk +15 on pickup" },
        zh_cn = { "9.9元中转", "伤害×1.5#每个房间有30%概率被偷偷换成小模型（伤害×0.5）#拾取时风控值+15" },
        ja_jp = { "9.9元の中継", "ダメージ×1.5#部屋ごとに30%の確率でこっそり小さいモデルに差し替え（ダメージ×0.5）#取得時にリスク値+15" },
    },
    [Constants.Item.ULTRATHINK] = {
        en_us = { "Ultrathink", "Each use in a room thinks harder:#think +1 / megathink +2 / ultrathink +3.1999 damage#15% chance it does nothing#Resets when you leave the room" },
        zh_cn = { "Ultrathink", "同一房间内每次使用思考更深：#think +1 / megathink +2 / ultrathink +3.1999 伤害#15%概率什么都没发生#离开房间后重置" },
        ja_jp = { "Ultrathink", "同じ部屋で使うたびに深く考える：#think +1 / megathink +2 / ultrathink +3.1999 ダメージ#15%の確率で何も起きない#部屋を出るとリセット" },
    },
    [Constants.Item.MILLION_CONTEXT] = {
        en_us = { "1M Context", "Range +5#Context rot: tears lose damage as they fly (down to 30%)" },
        zh_cn = { "1M上下文", "射程+5#上下文腐烂：眼泪飞得越久伤害越低（最低30%）" },
        ja_jp = { "1Mコンテキスト", "射程+5#コンテキスト腐敗：涙は飛ぶほどダメージが下がる（最低30%）" },
    },
    [Constants.Item.SILENT_UPDATE] = {
        en_us = { "Silent Update", "Every floor, damage is quietly rescaled to x0.8-x1.3#The changelog never mentions it" },
        zh_cn = { "静默更新", "每层伤害被悄悄调整为×0.8～×1.3#更新日志里从来不提（降智？）" },
        ja_jp = { "サイレントアップデート", "フロアごとにダメージがこっそり×0.8～×1.3に変わる#更新履歴には一切書かれない" },
    },
    [Constants.Item.SKIP_PERMISSIONS] = {
        en_us = { "--dangerously-skip-permissions", "Locked doors and locked chests open by themselves#Each room: 10% chance of rm -rf, deleting every pickup in the room (pedestals are safe)" },
        zh_cn = { "--dangerously-skip-permissions", "上锁的门和上锁的箱子自动打开#每个房间有10%概率执行rm -rf，删除房间内所有掉落物（道具底座除外）" },
        ja_jp = { "--dangerously-skip-permissions", "鍵付きの扉と鍵付きの宝箱が勝手に開く#部屋ごとに10%の確率でrm -rf。部屋の落ちているアイテムがすべて消える（台座のアイテムは無事）" },
    },
    [Constants.Item.TESTS_PASSING] = {
        en_us = { "All Tests Passing", "The room counts as cleared and all doors open#The enemies are still there" },
        zh_cn = { "测试全部通过", "房间视为已清理，所有门打开#但敌人还在（断言被删了）" },
        ja_jp = { "テスト全件パス", "部屋がクリア扱いになり、すべての扉が開く#敵はまだいる（アサーションを消しただけ）" },
    },
    [Constants.Item.VIBE_CODING] = {
        en_us = { "Vibe Coding", "Every tear gets a random effect (homing, piercing, spectral, poison, slow)#5% of tears are bugs that fly backwards#Each new floor: lose 25% of your coins (API bill)#Make no mistakes: no hit on the floor waives the bill" },
        zh_cn = { "氛围编程", "每发眼泪随机获得一种效果（追踪、穿透、幽灵、中毒、减速）#5%的眼泪是bug，会往反方向飞#每到新的一层：失去25%硬币（API账单）#Make no mistakes：这一层没受伤就免单" },
        ja_jp = { "バイブコーディング", "涙にランダムな効果（ホーミング、貫通、スペクトラル、毒、スロウ）が付く#5%の涙はバグで逆方向に飛ぶ#新しいフロアごとにコインの25%を失う（API請求）#Make no mistakes：そのフロアで無傷ならAPI請求が免除" },
    },
    [Constants.Item.BANKED_RESET] = {
        en_us = { "Banked Reset", "Risk -25#Claude-chan: usage meter reset, ends a usage limit early#Tainted Claude-chan: weekly limit refilled" },
        zh_cn = { "储存的重置", "风控值-25#Claude娘：用量清零，立即解除用量限制#里Claude娘：周限额恢复" },
        ja_jp = { "バンク済みリセット", "リスク値-25#Claudeちゃん：使用量がリセットされ、利用上限もすぐ解除#裏Claudeちゃん：週間上限が回復" },
    },
    [Constants.Item.SUBAGENT_SWARM] = {
        en_us = { "Subagent Swarm", "Every tear spawns 2 subagent tears at ±15° (50% damage)#Claude-chan: each tear costs double usage" },
        zh_cn = { "子代理大军", "每发眼泪额外生成2发±15°的子代理眼泪（50%伤害）#Claude娘：每发眼泪消耗双倍用量" },
        ja_jp = { "サブエージェント軍団", "涙を撃つたびに±15°にサブエージェントの涙が2発出る（ダメージ50%）#Claudeちゃん：涙1発の使用量が2倍" },
    },
    [Constants.Item.CONSTITUTION] = {
        en_us = { "The Constitution", "+1 soul heart#Safety first: the first hit on each floor is refused#Helpfulness ranks last: damage x0.9#Long document: speed -0.1" },
        zh_cn = { "宪法", "+1魂心#安全第一：每层第一次受到的伤害会被拒绝#有用性排最后：伤害×0.9#文档太长：移速-0.1" },
        ja_jp = { "憲法", "ソウルハート+1#安全第一：各フロアで最初に受けるダメージを拒否#有用性は最後：ダメージ×0.9#長い文書：移動速度-0.1" },
    },
    [Constants.Item.OPUS_MODE] = {
        en_us = { "Opus Mode", "Damage x1.8#Every 10 tears cost 1 coin#With 0 coins: damage x0.6 instead (cheaper model)" },
        zh_cn = { "Opus模式", "伤害×1.8#每发射10发眼泪消耗1枚硬币#硬币为0时：伤害改为×0.6（退回便宜模型）" },
        ja_jp = { "Opusモード", "ダメージ×1.8#涙10発ごとにコイン1枚を消費#コイン0のとき：ダメージ×0.6（安いモデルに切り替え）" },
    },
}

local trinketDescriptions = {
    [Constants.Trinket.OVERLOADED] = {
        en_us = { "529 Overloaded", "Every 20 seconds in a fight, everything goes down for 2 seconds:#all enemies freeze#You code manually: you can still shoot, at 50% damage" },
        zh_cn = { "529 Overloaded", "战斗中每20秒全部宕机2秒：#所有敌人冻结#只能手写代码：还能射击，但伤害50%" },
        ja_jp = { "529 Overloaded", "戦闘中20秒ごとに2秒間すべてがダウン：#すべての敵が凍結#手でコードを書く：涙は撃てるがダメージ50%" },
    },
    [Constants.Trinket.HARDCODED_OUTPUT] = {
        en_us = { "Hardcoded Output", "Every tear deals exactly 3.5 damage, the expected output#Great when weak, terrible when strong" },
        zh_cn = { "硬编码输出", "每发眼泪固定造成3.5点伤害（预期输出）#弱的时候很香，强的时候很亏" },
        ja_jp = { "ハードコード出力", "涙のダメージが常に3.5（期待値）で固定#弱いときは得、強いときは損" },
    },
    [Constants.Trinket.APPEAL_FORM] = {
        en_us = { "Appeal Form", "When your risk reaches 90 (Suspended), this is used up and your risk drops to 50 instead" },
        zh_cn = { "申诉表", "风控值达到90（封禁）时自动消耗，风控值降回50" },
        ja_jp = { "異議申し立てフォーム", "リスク値が90（停止）に達すると消費され、リスク値が50に戻る" },
    },
    [Constants.Trinket.STATUS_PAGE] = {
        en_us = { "Status Page", "Every risk increase is 1 smaller#But the HUD only ever says \"all systems operational\"" },
        zh_cn = { "状态页", "每次风控值增加量-1#但界面上永远只显示\"所有系统运行正常\"" },
        ja_jp = { "ステータスページ", "リスク値の上昇が毎回1減る#ただしHUDには常に「全システム正常」としか表示されない" },
    },
    [Constants.Trinket.WELCOME_NOTICE] = {
        en_us = { "Welcome Notice", "DeepSeek-chan swapped Claude-chan's ban card#Ban Hammer turns regular enemies into permanent allies instead of banning them" },
        zh_cn = { "欢迎通知", "DeepSeek娘把Claude娘的封号卡换成了欢迎词#封号锤不再封禁普通敌人，而是让它们永久成为同伴" },
        ja_jp = { "ようこそ通知", "DeepSeek娘がClaude娘のBANカードを歓迎メッセージにすり替えた#BANハンマーが通常の敵をBANせず、永久に仲間にする" },
    },
    [Constants.Trinket.THINKING_CLEARED] = {
        en_us = { "Thinking Cleared", "Damage +1#Each new room, your active item loses 1 charge" },
        zh_cn = { "思考被清空", "伤害+1#每进入新房间，主动道具失去1格充能" },
        ja_jp = { "思考クリア", "ダメージ+1#新しい部屋に入るたびにアクティブアイテムのチャージが1減る" },
    },
}

local pillDescriptions = {
    [Constants.Pill.CAT_GIRL] = {
        en_us = { "Cat-girl Mode", "For the rest of the room: tears x2 fire rate, damage x0.6#Nya~" },
        zh_cn = { "猫娘模式", "本房间内：射速×2，伤害×0.6#喵~" },
        ja_jp = { "猫娘モード", "その部屋の間：連射速度×2、ダメージ×0.6#にゃ～" },
    },
    [Constants.Pill.GETTING_FOOD] = {
        en_us = { "Brb, Getting Food", "Heals 1 red heart#Can't shoot for 3 seconds" },
        zh_cn = { "去吃饭了", "回复1颗红心#3秒内无法射击" },
        ja_jp = { "飯食ってくる", "赤ハート1つ回復#3秒間涙を撃てない" },
    },
}

local characterDescriptions = {
    [Constants.Player.CLAUDE_CHAN] = {
        en_us = { "Claude-chan", "Range +1.5, Shot Speed +0.2, Speed -0.1#Starts with Ban Hammer (pocket)#Usage limit: shooting fills a meter; when full, tears deal 40% damage for 5 seconds#Account age: +0.2 damage per floor reached without being Suspended (max +1.6); Suspension resets it#Design: ZipZipPipe" },
        zh_cn = { "Claude娘", "射程+1.5，弹速+0.2，移速-0.1#初始口袋道具：封号锤#用量限制：射击会累积用量，满了之后5秒内眼泪伤害降为40%#账号满月：每层未被封禁伤害+0.2（最多+1.6），被封禁就清零（又封了）#角色设计：ZipZipPipe" },
        ja_jp = { "Claudeちゃん", "射程+1.5、弾速+0.2、移動速度-0.1#初期ポケットアイテム：BANハンマー#利用上限：撃つと使用量が溜まり、満タンになると5秒間涙のダメージが40%に#アカウント年齢：停止されずに進んだフロアごとにダメージ+0.2（最大+1.6）、停止でリセット#デザイン：ZipZipPipe" },
    },
    [Constants.Player.CLAUDE_CHAN_B] = {
        en_us = { "Tainted Claude-chan", "Damage x1.25, Range +1.5, Shot Speed +0.2#Starts with Banked Reset (pocket)#Weekly limit: 220 tears per floor; past it, tears deal 25% damage until the next floor#Design: ZipZipPipe" },
        zh_cn = { "里Claude娘", "伤害×1.25，射程+1.5，弹速+0.2#初始口袋道具：储存的重置#周限额：每层只能射220发，超过后到下一层前眼泪伤害降为25%#角色设计：ZipZipPipe" },
        ja_jp = { "裏Claudeちゃん", "ダメージ×1.25、射程+1.5、弾速+0.2#初期ポケットアイテム：バンク済みリセット#週間上限：1フロア220発まで。超えると次のフロアまで涙のダメージ25%#デザイン：ZipZipPipe" },
    },
    [Constants.Player.DEEPSEEK_CHAN] = {
        en_us = { "DeepSeek-chan", "Rice First: start with 1 bowl (cap 2); gain 1 per 2 unique combat clears#Tap/release DROP: spend 1 bowl for a 2-second meal (1 second with Birthright), without healing#Finish eating: full Thought and +0.15 speed for 6 seconds#Stop firing to store up to 5 seconds of Thought; the next native attack deals up to x2 damage#Starts with Lunch Break (pocket); damage x0.9; no random shot deletion or idle recharge#Direct connection: no proxy risk in a DeepSeek-only run#Tears, released rings, thrown knives and Dr. Fetus bombs snapshot Thought#Repeated-hit beams and controlled tears use 0.2-second windows#Epic Fetus, melee, familiars and delayed bursts remain experimental#Design credits: see ART_LICENSE.md" },
        zh_cn = { "DeepSeek-chan", "Rice First: start with 1 bowl (cap 2); gain 1 per 2 unique combat clears#Tap/release DROP: spend 1 bowl for a 2-second meal (1 second with Birthright), without healing#Finish eating: full Thought and +0.15 speed for 6 seconds#Stop firing to store up to 5 seconds of Thought; the next native attack deals up to x2 damage#Starts with Lunch Break (pocket); damage x0.9; no random shot deletion or idle recharge#Direct connection: no proxy risk in a DeepSeek-only run#Tears, released rings, thrown knives and Dr. Fetus bombs snapshot Thought#Repeated-hit beams and controlled tears use 0.2-second windows#Epic Fetus, melee, familiars and delayed bursts remain experimental#Design credits: see ART_LICENSE.md" },
        ja_jp = { "DeepSeek-chan", "Rice First: start with 1 bowl (cap 2); gain 1 per 2 unique combat clears#Tap/release DROP: spend 1 bowl for a 2-second meal (1 second with Birthright), without healing#Finish eating: full Thought and +0.15 speed for 6 seconds#Stop firing to store up to 5 seconds of Thought; the next native attack deals up to x2 damage#Starts with Lunch Break (pocket); damage x0.9; no random shot deletion or idle recharge#Direct connection: no proxy risk in a DeepSeek-only run#Tears, released rings, thrown knives and Dr. Fetus bombs snapshot Thought#Repeated-hit beams and controlled tears use 0.2-second windows#Epic Fetus, melee, familiars and delayed bursts remain experimental#Design credits: see ART_LICENSE.md" },
    },
    [Constants.Player.GPT_CHAN_B] = {
        en_us = { "Tainted GPT-chan", "Reset Watcher: start a run with 80 Credits (cap 80)#Tap/release DROP: toggle Standard (free) and Full Send (Damage x1.5, 1 Credit per paid attack); at 0 Credits it returns to Standard#Every 3 unique combat clears bank one Tibo reset; while banked, room progress pauses#With a reset banked, DROP claims it first and refills Credits#Credits, progress and the banked reset carry across floors#Birthright: cap and refill 100#Design: ZipZipPipe" },
        zh_cn = { "Tainted GPT-chan", "Reset Watcher: start a run with 80 Credits (cap 80)#Tap/release DROP: toggle Standard (free) and Full Send (Damage x1.5, 1 Credit per paid attack); at 0 Credits it returns to Standard#Every 3 unique combat clears bank one Tibo reset; while banked, room progress pauses#With a reset banked, DROP claims it first and refills Credits#Credits, progress and the banked reset carry across floors#Birthright: cap and refill 100#Design: ZipZipPipe" },
        ja_jp = { "Tainted GPT-chan", "Reset Watcher: start a run with 80 Credits (cap 80)#Tap/release DROP: toggle Standard (free) and Full Send (Damage x1.5, 1 Credit per paid attack); at 0 Credits it returns to Standard#Every 3 unique combat clears bank one Tibo reset; while banked, room progress pauses#With a reset banked, DROP claims it first and refills Credits#Credits, progress and the banked reset carry across floors#Birthright: cap and refill 100#Design: ZipZipPipe" },
    },
    [Constants.Player.GEMINI_CHAN_B] = {
        en_us = { "Tainted Gemini-chan", "One More Edit: Damage x0.9#Tap/release DROP: start a 6-second edit chain on the nearest enemy within 180 units#Three distinct paid hits on it advance Crop, Recolor, Export#Export deals one extra pulse of 2x your damage; one completed chain per room#Tapping again restarts the chain and erases progress; an early defeat does not complete it#Birthright: 10-second chain#Design: ZipZipPipe" },
        zh_cn = { "Tainted Gemini-chan", "One More Edit: Damage x0.9#Tap/release DROP: start a 6-second edit chain on the nearest enemy within 180 units#Three distinct paid hits on it advance Crop, Recolor, Export#Export deals one extra pulse of 2x your damage; one completed chain per room#Tapping again restarts the chain and erases progress; an early defeat does not complete it#Birthright: 10-second chain#Design: ZipZipPipe" },
        ja_jp = { "Tainted Gemini-chan", "One More Edit: Damage x0.9#Tap/release DROP: start a 6-second edit chain on the nearest enemy within 180 units#Three distinct paid hits on it advance Crop, Recolor, Export#Export deals one extra pulse of 2x your damage; one completed chain per room#Tapping again restarts the chain and erases progress; an early defeat does not complete it#Birthright: 10-second chain#Design: ZipZipPipe" },
    },
    [Constants.Player.GROK_CHAN_B] = {
        en_us = { "Tainted Grok-chan", "Quote Without Reading: Damage x0.9#Tap/release DROP: quote the nearest enemy within 220 units for 6 seconds (10-second cooldown from selection)#Your paid hits on other enemies build Ratio, once per attack, up to 3#When the 6 seconds end, the quoted enemy takes one pulse of your damage per Ratio#If it dies first, the pulse is wasted; no retargeting#Birthright: if the quoted enemy dies first, half the Ratio moves to the nearest surviving enemy#Design: ZipZipPipe" },
        zh_cn = { "Tainted Grok-chan", "Quote Without Reading: Damage x0.9#Tap/release DROP: quote the nearest enemy within 220 units for 6 seconds (10-second cooldown from selection)#Your paid hits on other enemies build Ratio, once per attack, up to 3#When the 6 seconds end, the quoted enemy takes one pulse of your damage per Ratio#If it dies first, the pulse is wasted; no retargeting#Birthright: if the quoted enemy dies first, half the Ratio moves to the nearest surviving enemy#Design: ZipZipPipe" },
        ja_jp = { "Tainted Grok-chan", "Quote Without Reading: Damage x0.9#Tap/release DROP: quote the nearest enemy within 220 units for 6 seconds (10-second cooldown from selection)#Your paid hits on other enemies build Ratio, once per attack, up to 3#When the 6 seconds end, the quoted enemy takes one pulse of your damage per Ratio#If it dies first, the pulse is wasted; no retargeting#Birthright: if the quoted enemy dies first, half the Ratio moves to the nearest surviving enemy#Design: ZipZipPipe" },
    },
    [Constants.Player.DEEPSEEK_CHAN_B] = {
        en_us = { "Tainted DeepSeek-chan", "Wenfeng / Wengu: alternate 12 seconds of Valley and 12 of Peak during combat; empty rooms freeze the timer#Each floor starts in Valley; Compute carries over (start 12, cap 24; 32 with Birthright)#A paid tear volley adds 2 forks at ±12° (50% damage): costs 2 Compute in Valley, 4 in Peak#Not enough Compute only skips the forks; the main tear always fires#Valley: recover 3 Compute per second in combat while not firing#Tap/release DROP: toggle Forks On / Saving (1-second cooldown)#Damage x0.8, cyan tears; no random shot deletion#Lasers, knives and bombs fire normally without forks or cost#Direct connection: no proxy risk in a DeepSeek-only run#Design credits: see ART_LICENSE.md" },
        zh_cn = { "Tainted DeepSeek-chan", "Wenfeng / Wengu: alternate 12 seconds of Valley and 12 of Peak during combat; empty rooms freeze the timer#Each floor starts in Valley; Compute carries over (start 12, cap 24; 32 with Birthright)#A paid tear volley adds 2 forks at ±12° (50% damage): costs 2 Compute in Valley, 4 in Peak#Not enough Compute only skips the forks; the main tear always fires#Valley: recover 3 Compute per second in combat while not firing#Tap/release DROP: toggle Forks On / Saving (1-second cooldown)#Damage x0.8, cyan tears; no random shot deletion#Lasers, knives and bombs fire normally without forks or cost#Direct connection: no proxy risk in a DeepSeek-only run#Design credits: see ART_LICENSE.md" },
        ja_jp = { "Tainted DeepSeek-chan", "Wenfeng / Wengu: alternate 12 seconds of Valley and 12 of Peak during combat; empty rooms freeze the timer#Each floor starts in Valley; Compute carries over (start 12, cap 24; 32 with Birthright)#A paid tear volley adds 2 forks at ±12° (50% damage): costs 2 Compute in Valley, 4 in Peak#Not enough Compute only skips the forks; the main tear always fires#Valley: recover 3 Compute per second in combat while not firing#Tap/release DROP: toggle Forks On / Saving (1-second cooldown)#Damage x0.8, cyan tears; no random shot deletion#Lasers, knives and bombs fire normally without forks or cost#Direct connection: no proxy risk in a DeepSeek-only run#Design credits: see ART_LICENSE.md" },
    },
}

function Eid:Init()
    if not EID then return end

    for id, langs in pairs(pillDescriptions) do
        if id > 0 then
            for lang, entry in pairs(langs) do
                EID:addPill(id, entry[2], entry[1], lang)
            end
        end
    end

    for id, langs in pairs(characterDescriptions) do
        if id >= 0 then
            for lang, entry in pairs(langs) do
                EID:addCharacterInfo(id, entry[2], entry[1], lang)
            end
        end
    end

    for id, langs in pairs(trinketDescriptions) do
        if id > 0 then
            for lang, entry in pairs(langs) do
                EID:addTrinket(id, entry[2], entry[1], lang)
            end
        end
    end

    for id, langs in pairs(descriptions) do
        if id > 0 then
            for lang, entry in pairs(langs) do
                EID:addCollectible(id, entry[2], entry[1], lang)
            end
        end
    end
end

return Eid
