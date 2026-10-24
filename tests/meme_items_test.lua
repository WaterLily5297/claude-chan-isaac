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
ModCallbacks = { MC_USE_ITEM = "use", MC_EVALUATE_CACHE = "cache", MC_POST_FIRE_TEAR = "fire", MC_POST_NEW_ROOM = "room" }
CacheFlag = { CACHE_DAMAGE = 1, CACHE_SPEED = 16, CACHE_SHOTSPEED = 4, CACHE_TEARFLAG = 32, CACHE_RANGE = 8, CACHE_TEARCOLOR = 64 }
EntityFlag = { FLAG_FRIENDLY = 1, FLAG_CHARM = 2 }
TearFlags = { TEAR_KNOCKBACK = 1 << 9, TEAR_SLOW = 1 << 3, TEAR_SPECTRAL = 1 }
function EntityRef(e) return { Entity = e } end
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
local function npc(x, opts)
    opts = opts or {}
    local n = { Position = Vector(x, 0), Index = opts.index or x, flags = opts.flags or 0 }
    function n:ToNPC() if opts.notNpc then return nil end return self end
    function n:Exists() return true end
    function n:IsDead() return opts.dead or false end
    function n:IsVulnerableEnemy() return not opts.invulnerable end
    function n:IsBoss() return opts.boss or false end
    function n:HasEntityFlags(f) return (self.flags & f) ~= 0 end
    function n:AddCharmed(ref, frames) self.charm = frames; self.flags = self.flags | EntityFlag.FLAG_CHARM; self.by = ref.Entity end
    function n:AddConfusion(ref, frames) self.confused = frames; self.by = ref.Entity end
    return n
end
local p = { Position = Vector(0, 0) }
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
