-- Boundary and lifecycle regressions independent of the large smoke scenario.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = function(n) return n == "Support Ticket" and 800 or 801 end,
    GetPlayerTypeByName = function(n, tainted) return (n == "DeepSeek-chan" and 42 or 41) + (tainted and 100 or 0) end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function() return 50 end,
}
ModCallbacks = setmetatable({}, { __index = function(_, k) return k end })
CacheFlag = { CACHE_DAMAGE = 1, CACHE_FIREDELAY = 2, CACHE_TEARCOLOR = 4 }
EntityType = { ENTITY_PLAYER = 1 }
ActiveSlot = { SLOT_POCKET = 2 }
UseFlag = { USE_CARBATTERY = 32 }
function Color(...) return {...} end
local callbacks = {}
local mod = { AddCallback = function(_, id, fn) callbacks[id] = fn end }
local risk = { state = { risk = 50, silentMult = 1 } }
function risk:Get() return self.state.risk end
function risk:Add(n) self.state.risk = math.max(0, self.state.risk + n) end
local stage, stageType, seed, messages, draws = 1, 0, 123, {}, {}
function Game() return {
    GetLevel = function() return {
        GetStage = function() return stage end,
        GetStageType = function() return stageType end,
    } end,
    GetSeeds = function() return { GetStartSeed = function() return seed end } end,
    GetNumPlayers = function() return 2 end,
    GetFrameCount = function() return FRAME or 0 end,
    GetRoom = function() return { IsClear = function() return ROOMCLEAR ~= false end } end,
    GetHUD = function() return {
        IsVisible = function() return true end,
        ShowItemText = function(_, title) messages[#messages + 1] = title end,
    } end,
} end
local function player(kind)
    return { coins = 3, kind = kind, Damage = 10, MaxFireDelay = 9,
        GetNumCoins = function(p) return p.coins end,
        AddCoins = function(p, n) p.coins = p.coins + n end,
        GetPlayerType = function(p) return p.kind end,
        SetPocketActiveItem = function(p, id) p.pocket = id end,
        HasCollectible = function() return true end,
        AddCacheFlags = function() end, EvaluateItems = function() end }
end
local p, other = player(42), player(42)
function Isaac.GetPlayer(i) return i == 0 and p or other end
local function fire(id, ...) return callbacks[id](mod, ...) end

include("scripts.items.support_ticket"):Init(mod, risk)
local function use(flags) return fire("MC_USE_ITEM", 800, nil, p, flags or 0) end
assert(use().Discharge and p.coins == 0 and risk:Get() == 30)
assert(risk.state.reviewApproved)
assert(not use().Discharge and risk:Get() == 30)
p.coins = 3; risk.state.risk = 0
assert(not use().Discharge and p.coins == 3)
risk.state.risk = 10
assert(not use(32).Discharge and p.coins == 3 and risk:Get() == 10)
assert(use().Discharge and risk:Get() == 0 and p.coins == 0)

-- DeepSeek-chan: Deep Think, Server busy, Lunch Break pocket; tainted Open Source forks.
callbacks = {}
local roll = 0.99
function RNG() return { SetSeed = function() end, RandomFloat = function() return roll end } end
local enemies, spawned = 0, {}
Isaac.CountEnemies = function() return enemies end
EntityType.ENTITY_TEAR = 2
Isaac.Spawn = function(_, _, _, _, velocity)
    local t = { velocity = velocity }
    function t:ToTear() return self end
    function t:ResetSpriteScale() self.spriteScale=self.Scale end
    spawned[#spawned + 1] = t
    return t
end
function Isaac.GetScreenHeight() return 270 end
function Isaac.RenderText(text) draws[#draws + 1] = text end
local function tear(owner)
    return { SpawnerEntity = { ToPlayer = function() return owner end }, CollisionDamage = 4,
        Scale = 1, Variant = 0, Position = {}, Color = "c",
        TearFlags = 0, Height = -10, FallingSpeed = 0, FallingAcceleration = 0.5,
        HomingFriction = 0, KnockbackMultiplier = 1,
        Velocity = { Rotated = function(_, a) return a end },
        Remove = function(t) t.removed = true end }
end
p.GetData = function(pl) pl.data = pl.data or {}; return pl.data end
other.GetData = p.GetData
include("scripts.characters.deepseek_chan"):Init(mod, risk)
fire("MC_POST_GAME_STARTED", false)
assert(p.pocket == 801 and other.pocket == 801, "normal DeepSeek-chan starts with Lunch Break")
p.pocket = 900; fire("MC_POST_GAME_STARTED", true); assert(p.pocket == 900, "continue keeps the pocket item")
fire("MC_EVALUATE_CACHE", p, CacheFlag.CACHE_DAMAGE); assert(p.Damage == 9)
FRAME = 0; local t0 = tear(p); fire("MC_POST_FIRE_TEAR", t0); assert(t0.CollisionDamage == 4, "no thinking yet")
FRAME = 15; local t1 = tear(p); fire("MC_POST_FIRE_TEAR", t1); assert(t1.CollisionDamage == 4, "under 1 s is not thinking")
FRAME = 315; local t2 = tear(p); fire("MC_POST_FIRE_TEAR", t2)
assert(t2.CollisionDamage == 8, "5 s of thinking (capped) doubles damage")
fire("MC_POST_RENDER"); assert(draws[#draws] == "Thought for 5 s")
enemies, roll = 10, 0.2
FRAME = 400; local t3 = tear(p); fire("MC_POST_FIRE_TEAR", t3)
assert(t3.removed, "server busy with 10 enemies at roll 0.2 (< 25%)")
roll = 0.3; local t4 = tear(p); fire("MC_POST_FIRE_TEAR", t4)
assert(not t4.removed, "busy chance is capped at 25%")
p.kind = 142; enemies, roll = 0, 0.99
local fork = tear(p); fire("MC_POST_FIRE_TEAR", fork)
assert(#spawned == 2 and spawned[1].CollisionDamage == 2 and spawned[1].velocity == -12, "tainted forks two 50% tears")
fire("MC_EVALUATE_CACHE", p, CacheFlag.CACHE_DAMAGE); assert(math.abs(p.Damage - 9 * 0.8) < 1e-9)
p.kind = 42
-- 摸鱼: standing still 5 s in a cleared room recharges the pocket Lunch Break by one.
ActiveSlot.SLOT_POCKET = 2
p.Velocity = { Length = function() return 0 end }
p.charge = 2
p.GetActiveItem = function() return 801 end
p.GetActiveCharge = function(pl) return pl.charge end
p.SetActiveCharge = function(pl, c) pl.charge = c end
ROOMCLEAR = false
for _ = 1, 200 do fire("MC_POST_PEFFECT_UPDATE", p) end
assert(p.charge == 2, "no slacking during a fight")
ROOMCLEAR = true
for _ = 1, 149 do fire("MC_POST_PEFFECT_UPDATE", p) end
assert(p.charge == 2, "not yet 5 s")
fire("MC_POST_PEFFECT_UPDATE", p); assert(p.charge == 3, "5 s of slacking: +1 charge")
p.charge = 6; for _ = 1, 300 do fire("MC_POST_PEFFECT_UPDATE", p) end
assert(p.charge == 6, "never above the item's 6 charges")
print("OK: DeepSeek-chan Deep Think, server busy, slacking off, pocket item and tainted forks")

callbacks = {}
local seeded
function RNG() return {
    SetSeed = function(_, s) seeded = s end,
    RandomFloat = function() assert(seeded, "random draw before seeding"); return (seeded % 100) / 100 end,
} end
include("scripts.items.silent_update"):Init(mod, risk)
fire("MC_POST_NEW_LEVEL") -- The actual engine calls this BEFORE GAME_STARTED.
assert(seeded and risk.state.silentMult >= 0.8 and risk.state.silentMult <= 1.3)
stage = 3; fire("MC_POST_NEW_LEVEL"); local a = risk.state.silentMult
fire("MC_POST_NEW_LEVEL"); assert(a == risk.state.silentMult)
risk.state.silentMult = 1.234
fire("MC_POST_GAME_STARTED", true); assert(risk.state.silentMult == 1.234)

callbacks = {}; Options = { Language = "en" }; draws = {}
function Isaac.RenderText(text) draws[#draws + 1] = text end
function Isaac.GetScreenHeight() return 270 end
include("scripts.story"):Init(mod, risk)
risk.state = { risk = 20 }; stage = 1
fire("MC_POST_NEW_LEVEL"); assert(risk.state.storySeen == nil)
fire("MC_POST_GAME_STARTED", false); fire("MC_POST_RENDER")
assert(risk.state.storySeen == 1 and draws[1] == "1. The shared address")
for _ = 1, 210 do fire("MC_POST_UPDATE") end
local before = #draws; fire("MC_POST_RENDER"); assert(#draws == before)
fire("MC_PRE_GAME_EXIT"); fire("MC_POST_NEW_LEVEL")
fire("MC_POST_GAME_STARTED", true); fire("MC_POST_RENDER"); assert(#draws == before)
local function finishCaption()
    for _ = 1, 210 do fire("MC_POST_UPDATE") end
end
stage = 3; fire("MC_POST_NEW_LEVEL"); assert(risk.state.storySeen == 3)
finishCaption()
stage = 5; fire("MC_POST_NEW_LEVEL"); assert(risk.state.storySeen == 7)
finishCaption()
risk.state.reviewApproved = true; fire("MC_POST_NEW_ROOM")
assert(risk.state.storySeen == 15)
fire("MC_POST_RENDER"); assert(draws[#draws - 1] == "4. A human finally read it")
print("OK: Support Ticket boundaries, duplicate use, co-op, seed lifecycle and saved story chapters")

-- Overlapping early review/floor callbacks must not overwrite captions or mark queued ones seen.
risk.state = { risk = 20 }; stage = 1; draws = {}
fire("MC_POST_GAME_STARTED", false)
risk.state.reviewApproved = true
fire("MC_POST_NEW_ROOM")
stage = 3; fire("MC_POST_NEW_LEVEL"); fire("MC_POST_NEW_ROOM")
fire("MC_POST_RENDER")
assert(risk.state.storySeen == 1 and draws[#draws - 1] == "1. The shared address")
assert(#risk.state.storyPending == 2, "duplicate room callback queued another review")
finishCaption(); fire("MC_POST_RENDER")
assert(risk.state.storySeen == 9 and draws[#draws - 1] == "4. A human finally read it")
assert(#risk.state.storyPending == 1 and risk.state.storyPending[1] == "story_2_reviewed")

-- Save/continue while a later chapter is still queued. Copy the persisted fields
-- into a distinct state table so the assertion cannot pass through shared identity.
local saved = { risk = 20, reviewApproved = true, storySeen = risk.state.storySeen,
    storyPending = {risk.state.storyPending[1]} }
fire("MC_PRE_GAME_EXIT")
risk.state = saved
fire("MC_POST_GAME_STARTED", true); fire("MC_POST_RENDER")
assert(risk.state.storySeen == 11 and #risk.state.storyPending == 0)
assert(draws[#draws] == "DeepSeek: Restored? Good. You are still welcome.")
finishCaption()
stage = 5; fire("MC_POST_NEW_LEVEL"); fire("MC_POST_RENDER")
assert(risk.state.storySeen == 15 and draws[#draws - 1] == "3. Beyond the queue")
local count = #draws
fire("MC_PRE_GAME_EXIT"); fire("MC_POST_GAME_STARTED", true); fire("MC_POST_RENDER")
assert(#draws == count, "completed chapters repeated after continue")

-- Legacy saves have no queue; stale/unknown queue entries do not block valid ones.
risk.state = { risk = 20, storySeen = 1, storyPending = {"unknown", "story_1", "story_2"} }
stage = 3
fire("MC_POST_GAME_STARTED", true); fire("MC_POST_RENDER")
assert(risk.state.storySeen == 3 and #risk.state.storyPending == 0)
assert(draws[#draws - 1] == "2. A welcome notice")
print("OK: overlapping captions queue, persist across continue and preserve early-approval dialogue")

-- An unknown-character fallback in Reactions Port Pack must not replace our skin.
local compat = include("scripts.compatibility.reaction_pack")
compat:Register(nil)
compat:Register({CostumeSets = {}})
local custom = {Apply = {99}, Remove = {98}}
local fallback = {Default = {Apply = {159}}, [41] = custom, [0] = {Apply = {1}}}
local pack = {CostumeSets = {Disabled = {IDs = {"Disabled"}},
    Ugh = {IDs = {"Ugh"}, Ugh = fallback}}}
compat:Register(pack)
assert(fallback[41] == custom, "preserve explicit character support")
assert(#fallback[42].Apply == 0 and #fallback[42].Remove == 0)
for _, id in ipairs({141, 142}) do
    assert(fallback[id] and #fallback[id].Apply == 0 and #fallback[id].Remove == 0,
        "tainted characters must opt out of the default Isaac reaction costume")
end
local taintedCustom = {Apply = {123}, Remove = {122}}
fallback[141] = taintedCustom
compat:Register(pack)
assert(fallback[141] == taintedCustom, "preserve explicit tainted character support")
assert(fallback.Default.Apply[1] == 159 and fallback[0].Apply[1] == 1)
local entry = fallback[42]; compat:Register(pack); assert(fallback[42] == entry)

-- The manual engine probe must leave no forced input behind on an early exit.
local ordinaryGame = Game
function Game()
    local game = ordinaryGame()
    game.GetFrameCount = function() return 100 end
    return game
end
Isaac.DebugString = function() end
local probeCallbacks, registrations = {}, 0
function RegisterMod()
    registrations = registrations + 1
    probeCallbacks = {}
    return {
        AddCallback = function(_, id, fn) probeCallbacks[id] = fn end,
        RemoveCallback = function(_, id) probeCallbacks[id] = nil end,
    }
end
local probe = include("tests.runtime_probe")
local owner = {}
stage = 3; p.kind = 41
assert(not pcall(function() probe:Run(owner, risk, function() end) end))
assert(registrations == 0 and not owner.ccProbeRunning)
stage = 1
probe:Run(owner, risk, function() end)
assert(owner.ccProbeRunning and probeCallbacks.MC_INPUT_ACTION)
assert(not pcall(function() probe:Run(owner, risk, function() end) end))
assert(registrations == 1, "duplicate probe registered another input callback")
probeCallbacks.MC_PRE_GAME_EXIT()
assert(not owner.ccProbeRunning and next(probeCallbacks) == nil)
probe:Run(owner, risk, function() end)
assert(registrations == 2 and owner.ccProbeRunning)
probeCallbacks.MC_PRE_GAME_EXIT()
print("OK: runtime probe preconditions, duplicate guard and exit cleanup")
