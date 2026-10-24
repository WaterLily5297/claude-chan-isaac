-- Boundary tests for Em Dash, Blueberry, Benchmaxxed and I Panicked.
-- Stubs model callback inputs only, not native piercing, splitting or damage.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
local ids = { ["Em Dash"] = 910, ["Blueberry"] = 911, ["Benchmaxxed"] = 912, ["I Panicked"] = 913, ["Strawberry"] = 903 }
Isaac = {
    GetItemIdByName = function(n) return ids[n] or 800 end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function() return 50 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = { MC_USE_ITEM = "use", MC_EVALUATE_CACHE = "cache", MC_POST_FIRE_TEAR = "fire", MC_POST_NEW_ROOM = "room" }
CacheFlag = { CACHE_DAMAGE = 1, CACHE_SHOTSPEED = 4, CACHE_TEARFLAG = 32 }
TearFlags = { TEAR_PIERCING = 1 << 1, TEAR_QUADSPLIT = 1 << 5 }
EntityFlag = { FLAG_FRIENDLY = 1 }
UseFlag = { USE_CARBATTERY = 32 }
RoomType = { ROOM_DEFAULT = 1, ROOM_BOSS = 5, ROOM_MINIBOSS = 6, ROOM_CHALLENGE = 11, ROOM_BOSSRUSH = 17, ROOM_TREASURE = 4 }
PickupVariant = { PICKUP_HEART = 10, PICKUP_COIN = 20, PICKUP_KEY = 30, PICKUP_BOMB = 40, PICKUP_CHEST = 50,
    PICKUP_GRAB_BAG = 69, PICKUP_PILL = 70, PICKUP_LIL_BATTERY = 90, PICKUP_COLLECTIBLE = 100,
    PICKUP_TAROTCARD = 300, PICKUP_TRINKET = 350 }
function EntityRef(e) return { Entity = e } end
function Color(r, g, b, a, ro, go, bo) return { R = r, G = g, B = b, A = a, RO = ro, GO = go, BO = bo } end
local captions, roomType, PLAYERS, entities = {}, RoomType.ROOM_DEFAULT, {}, {}
function Game() return {
    GetHUD = function() return { ShowItemText = function(_, a) captions[#captions + 1] = a end } end,
    GetRoom = function() return { GetType = function() return roomType end } end,
    GetNumPlayers = function() return #PLAYERS end } end
function Isaac.GetPlayer(i) return PLAYERS[i + 1] end
function Isaac.GetRoomEntities() return entities end

local callbacks = {}
local mod = { AddCallback = function(_, id, fn, item) callbacks[#callbacks + 1] = { id = id, fn = fn, item = item } end }
local function fire(id, ...)
    local result
    for _, cb in ipairs(callbacks) do if cb.id == id then result = cb.fn(mod, ...) end end
    return result
end
include("scripts.items.em_dash"):Init(mod)
include("scripts.items.blueberry"):Init(mod)
include("scripts.items.benchmaxxed"):Init(mod)
include("scripts.items.i_panicked"):Init(mod)
include("scripts.items.strawberry"):Init(mod)

local function player(items)
    local p = { Damage = 3.5, ShotSpeed = 1, TearFlags = 0, data = {}, evaluated = 0 }
    function p:HasCollectible(id) return (items[id] or 0) > 0 end
    function p:GetCollectibleNum(id) return items[id] or 0 end
    function p:GetData() return self.data end
    function p:ToPlayer() return self end
    function p:AddCacheFlags(f) self.pending = f end
    function p:EvaluateItems() self.evaluated = self.evaluated + 1 end
    return p
end
local function close(a, b) return math.abs(a - b) < 1e-9 end

-- Em Dash ---------------------------------------------------------------------
local plain = player({})
fire("cache", plain, CacheFlag.CACHE_SHOTSPEED); fire("cache", plain, CacheFlag.CACHE_TEARFLAG)
assert(plain.ShotSpeed == 1 and plain.TearFlags == 0, "no item, no change")
local dash = player({ [910] = 2 })
dash.TearFlags = 1 << 9
fire("cache", dash, CacheFlag.CACHE_SHOTSPEED); fire("cache", dash, CacheFlag.CACHE_TEARFLAG)
fire("cache", dash, CacheFlag.CACHE_DAMAGE)
assert(close(dash.ShotSpeed, 1.32), "+0.16 shot speed per copy")
assert(dash.TearFlags == (1 << 9) | TearFlags.TEAR_PIERCING, "piercing is added, existing flags kept")
assert(dash.Damage == 3.5, "damage untouched")
print("PASS Em Dash: per-copy shot speed, piercing flag, other stats untouched")

-- Blueberry -------------------------------------------------------------------
local function tear(p)
    local t = { SpawnerEntity = p, flags = 0, CollisionDamage = 3.5, Scale = 1,
        Color = Color(1, 1, 1, 1, 0, 0, 0) }
    function t:AddTearFlags(f) self.flags = self.flags | f end
    return t
end
local berry = player({ [911] = 1 })
local shots = {}
for i = 1, 6 do shots[i] = tear(berry); fire("fire", shots[i]) end
for i = 1, 6 do
    local split = (shots[i].flags & TearFlags.TEAR_QUADSPLIT) ~= 0
    assert(split == (i % 3 == 0), "every third tear splits: " .. i)
end
assert(shots[3].Color.B == 1 and shots[3].Color.R < 1 and shots[3].Color.BO > 0, "blue tint on the B tear")
assert(shots[3].CollisionDamage == 3.5, "no damage change")
local both = player({ [911] = 1, [903] = 1 })
both.data.ccStrawberry = 1
local combo = {}
for i = 1, 3 do combo[i] = tear(both); fire("fire", combo[i]) end
assert((combo[3].flags & TearFlags.TEAR_QUADSPLIT) ~= 0 and combo[3].CollisionDamage == 3.5, "B tear on the third shot")
assert(combo[2].CollisionDamage == 7 and combo[2].flags == 0, "Strawberry keeps its own count")
local noBerry = player({})
local t = tear(noBerry); fire("fire", t)
assert(t.flags == 0 and noBerry.data.ccBlueberry == nil, "no item, no count")
local orphan = tear(nil); fire("fire", orphan)
assert(orphan.flags == 0, "tears without a player spawner are ignored")
print("PASS Blueberry: every third tear splits, blue tint, independent of Strawberry")

-- Benchmaxxed -----------------------------------------------------------------
local bench = player({ [912] = 1 })
local function damage(p, rt) roomType = rt; p.Damage = 3.5; fire("cache", p, CacheFlag.CACHE_DAMAGE); return p.Damage end
for _, rt in ipairs({ RoomType.ROOM_BOSS, RoomType.ROOM_MINIBOSS, RoomType.ROOM_CHALLENGE, RoomType.ROOM_BOSSRUSH }) do
    assert(close(damage(bench, rt), 5), "benchmark room +1.5: " .. rt)
end
assert(close(damage(bench, RoomType.ROOM_DEFAULT), 3.15), "real-world room x0.9")
assert(close(damage(bench, RoomType.ROOM_TREASURE), 3.15), "treasure room is not a benchmark")
local double = player({ [912] = 2 })
assert(close(damage(double, RoomType.ROOM_BOSS), 6.5) and close(damage(double, RoomType.ROOM_DEFAULT), 3.5 * 0.81), "stacks per copy")
bench.ShotSpeed = 1; roomType = RoomType.ROOM_BOSS; fire("cache", bench, CacheFlag.CACHE_SHOTSPEED)
assert(bench.ShotSpeed == 1, "only the damage cache")
assert(close(damage(plain, RoomType.ROOM_BOSS), 3.5), "no item, no change")
PLAYERS = { bench, plain }
fire("room")
assert(bench.evaluated == 1 and bench.pending == CacheFlag.CACHE_DAMAGE and plain.evaluated == 0, "new room re-evaluates holders only")
print("PASS Benchmaxxed: benchmark rooms +1.5, others x0.9, per copy, new-room re-evaluation")

-- I Panicked ------------------------------------------------------------------
local function npc(hp, opts)
    opts = opts or {}
    local n = { HitPoints = hp, MaxHitPoints = hp, taken = 0 }
    function n:ToNPC() return self end
    function n:ToPickup() return nil end
    function n:IsDead() return opts.dead or false end
    function n:IsVulnerableEnemy() return not opts.invulnerable end
    function n:IsBoss() return opts.boss or false end
    function n:HasEntityFlags(f) return ((opts.flags or 0) & f) ~= 0 end
    function n:TakeDamage(amount, flags, source) self.taken = self.taken + amount; self.source = source.Entity; return true end
    return n
end
local function pickup(variant, shop)
    local p = { Variant = variant }
    function p:ToNPC() return nil end
    function p:ToPickup() return self end
    function p:IsShopItem() return shop or false end
    function p:Remove() self.removed = true end
    return p
end
local user = player({ [913] = 1 })
local function use(flags) return fire("use", 913, nil, user, flags or 0) end

local coin = pickup(PickupVariant.PICKUP_COIN)
entities = { coin, npc(10, { invulnerable = true }), npc(10, { flags = EntityFlag.FLAG_FRIENDLY }), npc(10, { dead = true }) }
local r = use()
assert(r.Discharge == false and not coin.removed and #captions == 0, "no target keeps the charge and deletes nothing")

local grunt, boss = npc(20), npc(400, { boss = true })
local loose = {}
for _, v in ipairs({ "PICKUP_HEART", "PICKUP_COIN", "PICKUP_KEY", "PICKUP_BOMB", "PICKUP_PILL",
        "PICKUP_TAROTCARD", "PICKUP_LIL_BATTERY", "PICKUP_GRAB_BAG" }) do
    loose[#loose + 1] = pickup(PickupVariant[v])
end
local safe = { pickup(PickupVariant.PICKUP_COLLECTIBLE), pickup(PickupVariant.PICKUP_TRINKET),
    pickup(PickupVariant.PICKUP_CHEST), pickup(PickupVariant.PICKUP_HEART, true) }
entities = { grunt, boss }
for _, p in ipairs(loose) do entities[#entities + 1] = p end
for _, p in ipairs(safe) do entities[#entities + 1] = p end
r = use()
assert(r.Discharge == true and r.ShowAnim == true and r.Remove == false)
assert(grunt.taken >= grunt.HitPoints and grunt.source == user, "non-boss takes lethal native damage from the player")
assert(close(boss.taken, 60), "boss loses 15% of max HP")
for _, p in ipairs(loose) do assert(p.removed, "loose consumable deleted: " .. p.Variant) end
for _, p in ipairs(safe) do assert(not p.removed, "pedestal, trinket, chest and shop item are safe: " .. p.Variant) end
assert(#captions == 1 and captions[1] == "I panicked")
r = use(UseFlag.USE_CARBATTERY)
assert(r.Discharge == true and close(boss.taken, 120) and #captions == 1, "Car Battery hits again without a second caption")
print("PASS I Panicked: lethal non-boss damage, 15% boss damage, consumables deleted, safe pickups kept")
