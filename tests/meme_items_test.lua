-- Boundary tests for Ignore All Previous Instructions, Tungsten Cube and Pizza Glue.
-- Stubs model callback inputs only, not native status, knockback or slowing.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
local ids = { ["Ignore All Previous Instructions"] = 900, ["Tungsten Cube"] = 901, ["Pizza Glue"] = 902,
    ["Strawberry"] = 903, ["Golden Gate Claude"] = 904 }
Isaac = {
    GetItemIdByName = function(n) return ids[n] or 800 end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function() return 50 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = { MC_USE_ITEM = "use", MC_EVALUATE_CACHE = "cache", MC_POST_FIRE_TEAR = "fire",
    MC_POST_NEW_ROOM = "room", MC_POST_GAME_STARTED = "start" }
UseFlag = { USE_CARBATTERY = 1 << 5, USE_OWNED = 1 << 2, USE_VOID = 1 << 6, USE_MIMIC = 1 << 7 }
CacheFlag = { CACHE_DAMAGE = 1, CACHE_SPEED = 16, CACHE_SHOTSPEED = 4, CACHE_TEARFLAG = 32, CACHE_RANGE = 8, CACHE_TEARCOLOR = 64 }
EntityFlag = { FLAG_FRIENDLY = 1, FLAG_CHARM = 2 }
TearFlags = { TEAR_KNOCKBACK = 1 << 9, TEAR_SLOW = 1 << 3, TEAR_SPECTRAL = 1 }
function EntityRef(e) return { Entity = e } end
function GetPtrHash(e) return e.pointer end
-- A removed entity invalidates its pointer; this does not model native lifetime.
function EntityPtr(e) return setmetatable({}, { __index = function(_, key)
    if key == "Ref" and not e.removed then return e end
end }) end
function Color(...) return { ... } end
local captions, roomClear, roomFirst, PLAYERS = {}, false, true, {}
function Game() return { GetHUD = function() return {
    ShowItemText = function(_, a, b) captions[#captions + 1] = a end } end,
    GetRoom = function() return { IsClear = function() return roomClear end,
        IsFirstVisit = function() return roomFirst end } end,
    GetNumPlayers = function() return #PLAYERS end } end
function Isaac.GetPlayer(i) return PLAYERS[i + 1] end
local vector = {}
vector.__index = vector
function Vector(x, y) return setmetatable({ X = x, Y = y }, vector) end
function vector.__sub(a, b) return Vector(a.X - b.X, a.Y - b.Y) end
function vector:LengthSquared() return self.X * self.X + self.Y * self.Y end

local callbacks = {}
local mod = { AddCallback = function(_, id, fn, item)
    callbacks[#callbacks + 1] = { id = id, fn = fn, item = item }
end }
local function fire(id, ...)
    local result
    for _, cb in ipairs(callbacks) do if cb.id == id then result = cb.fn(mod, ...) end end
    return result
end
include("scripts.items.ignore_instructions"):Init(mod)
include("scripts.items.tungsten_cube"):Init(mod)
include("scripts.items.pizza_glue"):Init(mod)
include("scripts.items.strawberry"):Init(mod)
include("scripts.items.golden_gate"):Init(mod)

-- Ignore All Previous Instructions ------------------------------------------
local entities = {}
function Isaac.GetRoomEntities() return entities end
local nextPointer = 100
local function npc(x, opts)
    opts = opts or {}
    nextPointer = nextPointer + 1
    local n = { Position = Vector(x, 0), Index = opts.index or x, flags = opts.flags or 0,
        pointer = opts.pointer or nextPointer, InitSeed = opts.seed or nextPointer }
    function n:ToNPC() if opts.notNpc then return nil end return self end
    function n:Exists() return not self.removed end
    function n:IsDead() return opts.dead or false end
    function n:IsVulnerableEnemy() return not opts.invulnerable end
    function n:IsBoss() return opts.boss or false end
    function n:HasEntityFlags(f) return (self.flags & f) ~= 0 end
    function n:AddCharmed(ref, frames)
        self.charm = frames; self.charmCalls = (self.charmCalls or 0) + 1
        if not opts.immune then self.flags = self.flags | EntityFlag.FLAG_CHARM end
        self.by = ref.Entity
    end
    function n:AddConfusion(ref, frames)
        self.confused = frames; self.confusionCalls = (self.confusionCalls or 0) + 1; self.by = ref.Entity
    end
    return n
end
local p = { Position = Vector(0, 0), pointer = 1, InitSeed = 1 }
function p:Exists() return not self.removed end
local function use(flags) return fire("use", 900, nil, p, flags or 0) end

entities = {}
assert(use().Discharge == false, "empty room keeps the charge")
entities = { npc(200.01), npc(5, { invulnerable = true }), npc(6, { flags = EntityFlag.FLAG_FRIENDLY }),
    npc(7, { dead = true }), npc(8, { notNpc = true }) }
assert(use().Discharge == false, "out-of-range, invulnerable, friendly, dead and non-NPC are ignored")
for _, e in ipairs(entities) do assert(not e.charm and not e.confused) end

local far, near, tieLow, tieHigh = npc(150), npc(40), npc(60, { index = 1 }), npc(60, { index = 2 })
entities = { far, tieHigh, near, tieLow }
assert(use().Discharge == true and near.charm == 240 and near.by == p)
assert(not far.charm and not tieLow.charm, "only one target per use")
-- Car Battery's second call picks the next nearest target that is not charmed.
assert(use(32).Discharge == true and tieLow.charm == 240 and not tieHigh.charm, "ties use entity index")
local boss = npc(10, { boss = true })
entities = { boss, far }
assert(use().Discharge == true and boss.confused == 60 and not boss.charm, "bosses are only confused")
print("PASS Ignore All Previous Instructions: range, eligibility, nearest/tie order, boss and Car Battery")

-- Pair the supplied primary/repeat callbacks without assuming a native frame delay.
local function inject(owner, flags, slot) return fire("use", 900, nil, owner, flags, slot) end
local function refused(result)
    assert(not result.Discharge and not result.Remove and not result.ShowAnim, "no target keeps all refusal fields")
end
local function accepted(result)
    assert(result.Discharge and not result.Remove and result.ShowAnim, "successful use preserves return fields")
end
local repeatFlags = UseFlag.USE_CARBATTERY | UseFlag.USE_OWNED | UseFlag.USE_VOID
for slot = 0, 3 do
    fire("start", false)
    local first, second = npc(10, { boss = true }), npc(20, { boss = true })
    entities = { second, first }
    accepted(inject(p, UseFlag.USE_OWNED, slot))
    accepted(inject(p, repeatFlags, slot))
    assert(first.confusionCalls == 1 and second.confusionCalls == 1,
        "Car Battery must select a different boss in each supplied active slot")
    assert(first.confused == 60 and second.confused == 60 and second.by == p)
    -- Confusion from this item or elsewhere never makes an ordinary use ineligible.
    accepted(inject(p, UseFlag.USE_VOID | UseFlag.USE_MIMIC, slot))
    assert(first.confusionCalls == 2, "a later non-repeat can select the same confused boss")
    local beforeCaptions = #captions
    entities = { first }
    refused(inject(p, repeatFlags, slot))
    assert(first.confusionCalls == 2 and #captions == beforeCaptions, "one-boss repeat has no new target or caption")
    accepted(inject(p, nil, slot))
    assert(first.confusionCalls == 3, "missing flags mean an ordinary use")
end

fire("room")
local immune, nextEnemy = npc(10, { immune = true }), npc(200)
entities = { nextEnemy, immune }
accepted(inject(p, 0, 0)); accepted(inject(p, repeatFlags, 0))
assert(immune.charmCalls == 1 and nextEnemy.charmCalls == 1 and nextEnemy.charm == 240,
    "a refused native status still cannot make the repeat reuse the selected enemy")

-- Interleaving owners and slots must not overwrite each other's first target.
fire("room")
local q = { Position = Vector(100, 0), pointer = 2, InitSeed = 2, Exists = p.Exists }
local left, right = npc(10, { boss = true }), npc(90, { boss = true })
entities = { left, right }
accepted(inject(p, 0, 0)); accepted(inject(q, 0, 0))
accepted(inject(p, repeatFlags, 0)); accepted(inject(q, repeatFlags, 0))
assert(left.confusionCalls == 2 and right.confusionCalls == 2 and left.by == q and right.by == p,
    "co-op repeat excludes only its own primary target")
fire("room")
accepted(inject(p, 0, 0))
p.Position = Vector(100, 0)
accepted(inject(p, 0, 1))
p.Position = Vector(0, 0)
accepted(inject(p, repeatFlags, 0))
assert(left.confusionCalls == 3 and right.confusionCalls == 4,
    "slot zero repeats against its own primary before slot one repeats")
p.Position = Vector(100, 0)
accepted(inject(p, repeatFlags, 1))
assert(left.confusionCalls == 4 and right.confusionCalls == 4, "active slots retain independent primary targets")
p.Position = Vector(0, 0)

fire("room")
accepted(inject(p, 0, 0))
p.Position = Vector(100, 0)
accepted(inject(p, 0, 0))
accepted(inject(p, repeatFlags, 0))
assert(left.confusionCalls == 6 and right.confusionCalls == 5,
    "a new primary in the same slot replaces the old target even before a repeat")
p.Position = Vector(0, 0)

fire("room")
local wrapped, alternate = npc(10, { boss = true }), npc(20, { boss = true })
entities = { wrapped, alternate }
accepted(inject(p, 0, 0))
local alias = setmetatable({}, { __index = wrapped })
entities = { alias, alternate }
accepted(inject(p, repeatFlags, 0))
assert(wrapped.confusionCalls == 1 and alternate.confusionCalls == 1 and rawget(alias, "confusionCalls") == nil,
    "different Lua wrappers for the same entity cannot evade the exclusion")

-- Replacement, refusal, consumption and lifecycle boundaries retire old pairing.
local function solo()
    fire("room")
    local target = npc(10, { boss = true })
    entities = { target }
    accepted(inject(p, 0, 0))
    return target
end
local target = solo()
entities = {}
refused(inject(p, 0, 0))
entities = { target }
accepted(inject(p, repeatFlags, 0))
assert(target.confusionCalls == 2, "a refused new primary clears a previous successful primary")
target = solo()
refused(inject(p, repeatFlags, 0))
accepted(inject(p, repeatFlags, 0))
assert(target.confusionCalls == 2, "an unpaired repeat retains ordinary target selection after the pair is consumed")
for _, reset in ipairs({ "room", "start" }) do
    target = solo()
    fire(reset, true)
    accepted(inject(p, repeatFlags, 0))
    assert(target.confusionCalls == 2, "room entry or game start clears pairing")
end
target = solo()
target.removed = true
local replacement = npc(10, { boss = true, index = target.Index, pointer = target.pointer, seed = target.InitSeed + 1 })
entities = { replacement }
accepted(inject(p, repeatFlags, 0))
assert(replacement.confusionCalls == 1, "a recycled target pointer/index does not inherit exclusion")
target = solo()
target.InitSeed = target.InitSeed + 1
accepted(inject(p, repeatFlags, 0))
assert(target.confusionCalls == 2, "a changed target seed invalidates its exclusion")
target = solo()
local oldSeed = p.InitSeed
p.InitSeed = oldSeed + 1
accepted(inject(p, repeatFlags, 0))
assert(target.confusionCalls == 2, "a changed owner seed invalidates its pairing")
p.InitSeed = oldSeed
target = solo()
p.removed = true
local replacementOwner = { Position = p.Position, pointer = p.pointer, InitSeed = p.InitSeed, Exists = p.Exists }
accepted(inject(replacementOwner, repeatFlags, 0))
assert(target.confusionCalls == 2 and target.by == replacementOwner, "an expired owner pointer cannot exclude a target")
p.removed = nil
fire("room")
print("PASS Ignore All Previous Instructions: distinct repeats, slots, owners, refusal and transient identity cleanup")

-- Tungsten Cube ---------------------------------------------------------------
local function player(counts)
    local pl = { Damage = 3.5, MoveSpeed = 1, ShotSpeed = 1, Luck = 0, TearFlags = 0, counts = counts }
    function pl:GetCollectibleNum(id) return self.counts[id] or 0 end
    function pl:HasCollectible(id) return (self.counts[id] or 0) > 0 end
    function pl:ToPlayer() return self end
    return pl
end
local none = player({})
for _, flag in pairs(CacheFlag) do fire("cache", none, flag) end
assert(none.Damage == 3.5 and none.MoveSpeed == 1 and none.ShotSpeed == 1 and none.TearFlags == 0)
local cube = player({ [901] = 2 })
fire("cache", cube, CacheFlag.CACHE_DAMAGE); fire("cache", cube, CacheFlag.CACHE_SPEED)
fire("cache", cube, CacheFlag.CACHE_TEARFLAG); fire("cache", cube, CacheFlag.CACHE_TEARFLAG)
assert(math.abs(cube.Damage - 5.1) < 1e-9 and math.abs(cube.MoveSpeed - 0.7) < 1e-9)
assert(cube.TearFlags == TearFlags.TEAR_KNOCKBACK, "flag is OR-ed once, other flags kept")
local slow = player({ [901] = 1 }); slow.MoveSpeed = 0.2
fire("cache", slow, CacheFlag.CACHE_SPEED); assert(slow.MoveSpeed == 0.1, "speed floor")
local slower = player({ [901] = 1 }); slower.MoveSpeed = 0.05
fire("cache", slower, CacheFlag.CACHE_SPEED); assert(slower.MoveSpeed == 0.05, "never raises a lower speed")
print("PASS Tungsten Cube: per-copy damage/speed, speed floor and knockback flag")

-- Pizza Glue --------------------------------------------------------------------
local Glue = include("scripts.items.pizza_glue")
assert(Glue.Chance(0) == 0.25 and Glue.Chance(-10) == 0.10 and Glue.Chance(100) == 0.50)
local glue = player({ [902] = 1 })
fire("cache", glue, CacheFlag.CACHE_SHOTSPEED); assert(math.abs(glue.ShotSpeed - 0.9) < 1e-9)
local rolls, drawn = { 0.1, 0.9, 0.24, 0.25 }, 0
function glue:GetCollectibleRNG(id)
    assert(id == 902)
    return { RandomFloat = function() drawn = drawn + 1; return rolls[drawn] end }
end
local function tear(owner, flags)
    local t = { SpawnerEntity = owner, flags = flags or 0 }
    function t:HasTearFlags(f) return (self.flags & f) ~= 0 end
    function t:AddTearFlags(f) self.flags = self.flags | f end
    return t
end
local results = {}
for i = 1, 4 do local t = tear(glue); fire("fire", t); results[i] = t:HasTearFlags(TearFlags.TEAR_SLOW) end
assert(results[1] and not results[2] and results[3] and not results[4], "25% boundary is exclusive")
-- A sticky tear keeps the native item color underneath the glaze (Ipecac green here).
drawn, rolls[5] = 4, 0.1
local green = tear(glue); green.Color = { R = 0.5, G = 1, B = 0.5, A = 1, RO = 0, GO = 0.2, BO = 0 }
fire("fire", green); drawn = 4
assert(green.Color[1] == 0.5 and green.Color[2] == 1 and math.abs(green.Color[6] - 0.42) < 1e-9,
    "glue tints the native color instead of replacing it")
local already = tear(glue, TearFlags.TEAR_SLOW); fire("fire", already)
assert(drawn == 4 and already.Color == nil, "already-slow tears consume no roll")
fire("fire", tear(none)); fire("fire", tear(nil)); fire("fire", tear({ ToPlayer = function() return nil end }))
assert(drawn == 4, "other owners, familiars and unknown sources are not rolled")
print("PASS Pizza Glue: luck bounds, shot speed, native RNG roll, owner filter and no double roll")

-- Strawberry ----------------------------------------------------------------------
local berry = player({ [903] = 1 })
local bdata = {}
function berry:GetData() return bdata end
local function colored(owner)
    local t = tear(owner); t.CollisionDamage, t.Scale = 3, 1
    t.Color = { R = 1, G = 1, B = 1, A = 1, RO = 0, GO = 0, BO = 0 }
    return t
end
local shots = {}
for i = 1, 7 do shots[i] = colored(berry); fire("fire", shots[i]) end
for i = 1, 7 do
    local r = i % 3 == 0
    assert((shots[i].CollisionDamage == 6) == r and (shots[i].Scale == 1.2) == r, "every third tear only")
end
assert(shots[3].Color[3] == 0.35 and shots[3].Color[5] == 0.3, "red tint keeps the existing color")
local otherShot = colored(none); function none:GetData() error("non-holder data touched") end
fire("fire", otherShot); assert(otherShot.CollisionDamage == 3)
print("PASS Strawberry: per-player third-tear count, scaling multiplier, tint and owner filter")

-- Golden Gate Claude ------------------------------------------------------------------
local gate = player({ [904] = 1 })
gate.TearRange, gate.TearColor = 260, { R = 1, G = 1, B = 1, A = 1, RO = 0, GO = 0, BO = 0 }
fire("cache", gate, CacheFlag.CACHE_RANGE); fire("cache", gate, CacheFlag.CACHE_TEARFLAG)
fire("cache", gate, CacheFlag.CACHE_TEARCOLOR)
assert(gate.TearRange == 320 and gate.TearFlags == TearFlags.TEAR_SPECTRAL)
assert(gate.TearColor[3] == 0.5 and gate.TearColor[5] == 0.25, "golden tint")
local roll = 0.1
function gate:GetCollectibleRNG(id) assert(id == 904); return { RandomFloat = function() return roll end } end
PLAYERS = { none, gate }
captions = {}
roomClear = true; fire("room"); roomClear, roomFirst = false, false; fire("room")
assert(#captions == 0, "cleared or revisited rooms never mention the bridge")
roomFirst = true; fire("room"); roll = 0.9; fire("room")
assert(#captions == 1 and captions[1] == "I am the Golden Gate Bridge")
print("PASS Golden Gate Claude: range, spectral flag, tint and seeded caption")
