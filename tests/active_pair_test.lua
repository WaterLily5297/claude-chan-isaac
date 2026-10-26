-- Exercise two real active modules through item-filtered callback dispatch.
-- Supplied orders, damage/death and drops are fixtures, not native timing evidence.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
local INJECT, PANIC = 1801, 1802
local ids = { ["Ignore All Previous Instructions"] = INJECT, ["I Panicked"] = PANIC }
Isaac = {
    GetItemIdByName = function(name) return ids[name] or 800 end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function() return 50 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = { MC_USE_ITEM = "use", MC_POST_NEW_ROOM = "room", MC_POST_GAME_STARTED = "start" }
EntityFlag = { FLAG_FRIENDLY = 1, FLAG_CHARM = 2 }
UseFlag = { USE_OWNED = 4, USE_CARBATTERY = 32, USE_VOID = 64 }
PickupVariant = { PICKUP_HEART = 10, PICKUP_COIN = 20, PICKUP_KEY = 30, PICKUP_BOMB = 40,
    PICKUP_CHEST = 50, PICKUP_GRAB_BAG = 69, PICKUP_PILL = 70, PICKUP_LIL_BATTERY = 90,
    PICKUP_COLLECTIBLE = 100, PICKUP_TAROTCARD = 300, PICKUP_TRINKET = 350 }
function EntityRef(entity) return { Entity = entity } end
function GetPtrHash(entity) return entity.pointer end
function EntityPtr(entity) return setmetatable({}, { __index = function(_, key)
    if key == "Ref" and not entity.removed then return entity end
end }) end
local vector = {}; vector.__index = vector
function Vector(x, y) return setmetatable({ X = x, Y = y }, vector) end
function vector.__sub(a, b) return Vector(a.X - b.X, a.Y - b.Y) end
function vector:LengthSquared() return self.X * self.X + self.Y * self.Y end

local entities, captions, callbacks = {}, {}, {}
function Isaac.GetRoomEntities()
    local live = {}
    for _, entity in ipairs(entities) do if not entity.removed then live[#live + 1] = entity end end
    return live
end
function Game() return { GetHUD = function() return {
    ShowItemText = function(_, title) captions[#captions + 1] = title end,
} end } end
local mod = { AddCallback = function(_, id, fn, item)
    callbacks[#callbacks + 1] = { id = id, fn = fn, item = item }
end }
-- Same relative initialization order as main.lua; both callbacks share MC_USE_ITEM.
include("scripts.items.ignore_instructions"):Init(mod)
include("scripts.items.i_panicked"):Init(mod)
local function event(id, ...)
    for _, cb in ipairs(callbacks) do if cb.id == id then cb.fn(mod, ...) end end
end
local function use(item, owner, flags, slot)
    local result, count = nil, 0
    for _, cb in ipairs(callbacks) do
        if cb.id == "use" and (cb.item == nil or cb.item == item) then
            count = count + 1
            result = cb.fn(mod, item, nil, owner, flags, slot)
        end
    end
    assert(count == ((item == INJECT or item == PANIC) and 1 or 0),
        "each item dispatches only its registered use handler")
    return result
end
local function player(pointer)
    local p = { Position = Vector(0, 0), pointer = pointer, InitSeed = pointer }
    function p:Exists() return not self.removed end
    return p
end
local nextPointer = 100
local function boss(x, maximum, hp, onDamage)
    nextPointer = nextPointer + 1
    local n = { Position = Vector(x, 0), pointer = nextPointer, Index = nextPointer,
        InitSeed = nextPointer, MaxHitPoints = maximum, HitPoints = hp or maximum,
        taken = 0, hits = 0, confusions = 0 }
    function n:ToNPC() return self end
    function n:ToPickup() return nil end
    function n:Exists() return not self.removed end
    function n:IsDead() return self.HitPoints <= 0 end
    function n:IsVulnerableEnemy() return not self.removed end
    function n:IsBoss() return true end
    function n:HasEntityFlags() return false end
    function n:AddConfusion(ref, frames)
        self.confusions = self.confusions + 1; self.confusedBy = ref.Entity
        assert(frames == 60, "the pair preserves the existing boss status duration")
    end
    function n:TakeDamage(amount, _, ref)
        self.taken = self.taken + amount; self.hits = self.hits + 1
        self.HitPoints = self.HitPoints - amount; self.damagedBy = ref.Entity
        if self.HitPoints <= 0 then self.removed = true end
        if onDamage then onDamage(self) end
        return true
    end
    return n
end
local function pickup(variant, shop)
    local p = { Variant = variant, removes = 0 }
    function p:ToNPC() return nil end
    function p:ToPickup() return self end
    function p:IsShopItem() return shop or false end
    function p:Remove() self.removed = true; self.removes = self.removes + 1 end
    return p
end
local function accepted(result)
    assert(result and result.Discharge and result.ShowAnim and not result.Remove,
        "eligible pair effects keep their ordinary return fields")
end
local primaryFlags = UseFlag.USE_OWNED | UseFlag.USE_VOID
local repeatFlags = primaryFlags | UseFlag.USE_CARBATTERY
local owner, partner = player(1), player(2)
local orders = {
    { "inject", "inject-repeat", "panic", "panic-repeat" },
    { "inject", "panic", "inject-repeat", "panic-repeat" },
    { "panic", "inject", "panic-repeat", "inject-repeat" },
}
local sequences = 0
for slot = 0, 3 do
    for _, splitOwners in ipairs({ false, true }) do
        for _, order in ipairs(orders) do
            event("start", false)
            entities, captions = {}, {}
            local initial, drop, between = pickup(PickupVariant.PICKUP_COIN),
                pickup(PickupVariant.PICKUP_KEY), pickup(PickupVariant.PICKUP_HEART)
            local pedestal, shop = pickup(PickupVariant.PICKUP_COLLECTIBLE), pickup(PickupVariant.PICKUP_COIN, true)
            local first = boss(10, 400, nil, function(n)
                if n.hits == 1 then entities[#entities + 1] = drop end
            end)
            local second = boss(20, 200)
            local damageOwner = splitOwners and partner or owner
            entities = { first, second, initial, pedestal, shop }
            assert(use(9999, owner, primaryFlags, slot) == nil and #captions == 0
                and first.hits == 0 and first.confusions == 0 and not initial.removed,
                "an unrelated active does not run either module")
            local injections, damages = 0, 0
            for _, step in ipairs(order) do
                if step == "inject" or step == "inject-repeat" then
                    accepted(use(INJECT, owner, step == "inject" and primaryFlags or repeatFlags, slot))
                    injections = injections + 1
                else
                    accepted(use(PANIC, damageOwner, step == "panic" and primaryFlags or repeatFlags, slot))
                    damages = damages + 1
                    if step == "panic" then entities[#entities + 1] = between end
                end
                assert(first.confusions == math.min(1, injections) and second.confusions == math.max(0, injections - 1),
                    "other active callbacks must not reset or duplicate the pending injection target")
                assert(first.taken == 60 * damages and second.taken == 30 * damages
                    and first.hits == damages and second.hits == damages,
                    "only the damage active applies its two native damage calls")
                if injections > 0 then assert(first.confusedBy == owner) end
                if injections == 2 then assert(second.confusedBy == owner) end
                if damages > 0 then
                    assert(first.damagedBy == damageOwner and second.damagedBy == damageOwner)
                    assert(initial.removes == 1 and not drop.removed and not between.removed,
                        "the pair removes only the ordinary damage use's initial loose pickup")
                else assert(initial.removes == 0) end
                assert(not pedestal.removed and not shop.removed, "protected pickups survive both modules")
            end
            assert(#captions == 3, "two status captions and one ordinary damage caption")
            sequences = sequences + 1
        end
    end
end
assert(sequences == 24)
print("PASS active pair: 24 supplied orders, four slots, shared/separate owners and per-step effect isolation")

-- The damage active can remove the status active's first target before its repeat.
for slot = 0, 3 do
    event("room")
    captions = {}
    local initial, drop = pickup(PickupVariant.PICKUP_COIN), pickup(PickupVariant.PICKUP_KEY)
    local dying = boss(10, 100, 10, function() entities[#entities + 1] = drop end)
    local survivor = boss(20, 200)
    entities = { dying, survivor, initial }
    accepted(use(INJECT, owner, primaryFlags, slot))
    accepted(use(PANIC, partner, primaryFlags, slot))
    assert(dying.removed and dying.confusions == 1 and not drop.removed)
    accepted(use(INJECT, owner, repeatFlags, slot))
    assert(survivor.confusions == 1 and survivor.confusedBy == owner,
        "the surviving target receives the repeat after the partner's damage removes the first")
    accepted(use(PANIC, partner, repeatFlags, slot))
    assert(dying.hits == 1 and survivor.hits == 2 and survivor.taken == 60
        and initial.removes == 1 and not drop.removed and #captions == 3,
        "the removed target is not damaged again and its supplied drop survives the repeat")
end
print("PASS active pair: four interleaved target-death cases and supplied death-drop preservation")
