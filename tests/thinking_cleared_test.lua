-- Real item callbacks; supplied inventory/cache order is not native timing evidence.
local root, mode = arg[1] or ".", arg[2] or "all"
ModCallbacks = setmetatable({}, {__index = function(_, key) return key end})
CacheFlag = {CACHE_DAMAGE = 1, CACHE_SPEED = 2}
ActiveSlot = {SLOT_PRIMARY = 0, SLOT_SECONDARY = 1, SLOT_POCKET = 2}
local trinket = 192
function include(name)
    assert(name == "scripts.constants")
    return {Trinket = {THINKING_CLEARED = trinket}}
end
local callbacks, players, firstVisit = {}, {}, false
local mod = {}
function mod:AddCallback(id, fn)
    assert(not callbacks[id], "fixture expects one item callback per event")
    callbacks[id] = fn
end
local function fire(id, ...)
    if callbacks[id] then return callbacks[id](mod, ...) end
end
function Game() return {
    GetNumPlayers = function() return #players end,
    GetRoom = function() return {IsFirstVisit = function() return firstVisit end} end,
} end
Isaac = {GetPlayer = function(i) return players[i + 1] end}
local function player(held, base)
    local p = {held = held, base = base or 3.5, data = {}, Damage = base or 3.5,
        charges = {[0] = 4, [1] = 5, [2] = 6}, cacheCalls = 0, chargeWrites = 0}
    function p:GetData() return self.data end
    function p:HasTrinket(id) assert(id == trinket); return self.held end
    function p:AddCacheFlags(flag)
        assert(flag == CacheFlag.CACHE_DAMAGE, "only damage needs invalidating")
        self.pendingDamage = true
    end
    function p:EvaluateItems()
        assert(self.pendingDamage, "cache evaluation needs an invalidation")
        self.pendingDamage = false
        self.cacheCalls = self.cacheCalls + 1
        self.Damage = self.base
        fire("MC_EVALUATE_CACHE", self, CacheFlag.CACHE_DAMAGE)
    end
    function p:GetActiveCharge(slot) return self.charges[slot] end
    function p:SetActiveCharge(value, slot)
        assert(slot == ActiveSlot.SLOT_PRIMARY, "other active slots must be untouched")
        self.charges[slot] = value
        self.chargeWrites = self.chargeWrites + 1
    end
    return p
end
local function tick(p) fire("MC_POST_PEFFECT_UPDATE", p) end
local function rebuild(p, flag)
    p.Damage = p.base
    fire("MC_EVALUATE_CACHE", p, flag or CacheFlag.CACHE_DAMAGE)
end
local function case(name, fn)
    if mode == "all" or mode == name then
        players, firstVisit = {}, false
        fn()
        print("PASS Thinking Cleared " .. name)
    end
end
dofile(root .. "/scripts/items/thinking_cleared.lua"):Init(mod)

case("pickup", function()
    local p = player(false); players = {p}
    fire("MC_POST_NEW_ROOM")
    tick(p); assert(p.cacheCalls == 0, "an unheld trinket needs no rebuild")
    p.held = true; tick(p)
    assert(p.Damage == 4.5, "same-room pickup must apply the damage bonus")
    assert(p.cacheCalls == 1 and p.chargeWrites == 0, "pickup refreshes once without spending charge")
    for _ = 1, 120 do tick(p) end
    assert(p.cacheCalls == 1 and p.Damage == 4.5, "unchanged inventory must not rebuild or stack damage")
end)

case("drop", function()
    local p = player(true); players = {p}
    fire("MC_POST_NEW_ROOM"); assert(p.Damage == 4.5)
    p.held = false; tick(p)
    assert(p.Damage == 3.5, "same-room drop must remove the damage bonus")
    tick(p); assert(p.cacheCalls == 2 and p.chargeWrites == 0)
    p.held = true; tick(p)
    assert(p.Damage == 4.5 and p.cacheCalls == 3, "regaining the trinket refreshes once")
end)

case("cache_before_update", function()
    local p = player(false); players = {p}
    p.held = true; rebuild(p)
    assert(p.Damage == 4.5, "an immediate pickup cache must use current inventory before update")
    fire("MC_POST_NEW_ROOM")
    p.held = false; rebuild(p)
    assert(p.Damage == 3.5, "an immediate drop cache must ignore the stale room-entry flag")
    tick(p); assert(p.Damage == 3.5)
    p.held = true; p.base = 7; rebuild(p)
    assert(p.Damage == 8, "bonus is additive to freshly computed damage")
    rebuild(p); assert(p.Damage == 8, "repeated cache computation must not compound the bonus")
    rebuild(p, CacheFlag.CACHE_SPEED)
    assert(p.Damage == 7, "unrelated cache flags must not change damage")
end)

case("owners", function()
    local p, q = player(true), player(false, 5)
    players = {p, q}; fire("MC_POST_NEW_ROOM")
    p.held, q.held = false, true
    tick(q); assert(p.Damage == 4.5 and q.Damage == 6, "a partner update only refreshes that player")
    tick(p); assert(p.Damage == 3.5 and q.Damage == 6)
    for _ = 1, 20 do tick(p); tick(q) end
    assert(p.cacheCalls == 2 and q.cacheCalls == 1)
    local replacement = player(true, 6)
    players[1] = replacement; tick(replacement)
    assert(replacement.Damage == 7 and q.Damage == 6, "a new entity reads its own inventory")
    assert(p.chargeWrites == 0 and q.chargeWrites == 0 and replacement.chargeWrites == 0)
end)

case("charge_boundary", function()
    local p, q = player(true), player(false)
    players = {p, q}; firstVisit = true
    fire("MC_POST_NEW_ROOM")
    assert(p.charges[0] == 3 and q.charges[0] == 4, "only holders pay on first room entry")
    assert(p.charges[1] == 5 and p.charges[2] == 6)
    for _ = 1, 10 do tick(p); rebuild(p) end
    q.held = true; tick(q)
    assert(p.chargeWrites == 1 and q.chargeWrites == 0, "updates and pickup in a first-visit room cannot pay again")
    firstVisit = false; fire("MC_POST_NEW_ROOM")
    assert(p.charges[0] == 3 and q.charges[0] == 4, "revisits retain existing charge")
    p.charges[0] = 0; firstVisit = true; fire("MC_POST_NEW_ROOM")
    assert(p.charges[0] == 0 and p.chargeWrites == 1, "empty charge must not become negative")
    assert(q.charges[0] == 3 and q.chargeWrites == 1)
end)
