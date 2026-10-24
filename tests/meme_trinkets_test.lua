-- Boundary tests for Claudius's Discount, One Small Rock a Day, Stuck in Mt. Moon
-- and the 9.11 > 9.9 pill. Stubs model callback inputs and saved state only.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
local trinkets = { ["Claudius's Discount"] = 201, ["One Small Rock a Day"] = 202, ["Stuck in Mt. Moon"] = 203 }
Isaac = {
    GetItemIdByName = function() return 800 end,
    GetTrinketIdByName = function(n) return trinkets[n] or 190 end,
    GetPillEffectByName = function(n) return n == "9.11 > 9.9" and 60 or 50 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = setmetatable({}, { __index = function(_, k) return k end })
CacheFlag = { CACHE_DAMAGE = 1 }
PillColor = { PILL_GIANT_FLAG = 2048 }
function GetPtrHash(e) return e.hash end

local frame, floorSeed, stage, roomIndex, firstVisit, clear = 0, 7, 1, 10, true, true
local grid, mapEffects, captions = {}, 0, {}
function Game() return {
    GetFrameCount = function() return frame end,
    GetNumPlayers = function() return #PLAYERS end,
    GetLevel = function() return {
        GetDungeonPlacementSeed = function() return floorSeed end,
        GetStage = function() return stage end, GetStageType = function() return 0 end,
        GetCurrentRoomDesc = function() return { SafeGridIndex = roomIndex } end,
        ApplyMapEffect = function() mapEffects = mapEffects + 1 end,
    } end,
    GetRoom = function() return {
        IsFirstVisit = function() return firstVisit end, IsClear = function() return clear end,
        GetGridSize = function() return 5 end,
        GetGridEntity = function(_, i) return grid[i] end,
    } end,
    GetHUD = function() return { ShowItemText = function(_, a) captions[#captions + 1] = a end } end,
} end

local function player(hash)
    local p = { hash = hash, coins = 0, hearts = 2, canHeal = true, trinkets = {}, Damage = 3.5, evaluated = 0 }
    function p:ToPlayer() return self end
    function p:HasTrinket(id) return self.trinkets[id] == true end
    function p:GetNumCoins() return self.coins end
    function p:AddCoins(n) self.coins = math.max(0, self.coins + n) end
    function p:CanPickRedHearts() return self.canHeal end
    function p:AddHearts(n) self.hearts = self.hearts + n end
    function p:AddCacheFlags() end
    function p:EvaluateItems() self.evaluated = self.evaluated + 1; self.Damage = 3.5
        for _, cb in ipairs(CALLBACKS) do if cb.id == "MC_EVALUATE_CACHE" then cb.fn(MOD, self, CacheFlag.CACHE_DAMAGE) end end end
    return p
end
local p1, p2 = player(1), player(2)
PLAYERS = { p1, p2 }
function Isaac.GetPlayer(i) return PLAYERS[i + 1] end

CALLBACKS = {}
MOD = { AddCallback = function(_, id, fn, filter) CALLBACKS[#CALLBACKS + 1] = { id = id, fn = fn, filter = filter } end }
local function fire(id, ...)
    local result
    for _, cb in ipairs(CALLBACKS) do if cb.id == id then
        local r = cb.fn(MOD, ...); if r ~= nil then result = r end end end
    return result
end
local Risk = { state = {} }
include("scripts.items.claudius_discount"):Init(MOD, Risk)
include("scripts.items.small_rock"):Init(MOD, Risk)
include("scripts.items.mt_moon"):Init(MOD, Risk)
include("scripts.items.decimal_pill"):Init(MOD, Risk)
local function update() frame = frame + 1; fire("MC_POST_UPDATE") end

-- Claudius's Discount ------------------------------------------------------------
fire("MC_POST_NEW_LEVEL") -- before the run starts: ignored
fire("MC_POST_GAME_STARTED", false)
p1.trinkets[201], p1.coins = true, 10
local shopItem = { Price = 5 }
fire("MC_PRE_PICKUP_COLLISION", shopItem, p1)
p1.coins = 5; update()
assert(p1.coins == 6, "confirmed purchase refunds one coin")
update(); assert(p1.coins == 6, "one refund per purchase")
fire("MC_PRE_PICKUP_COLLISION", { Price = 1 }, p1); p1.coins = 5; update()
assert(p1.coins == 5, "1-coin items are not discounted")
p1.coins = 3; fire("MC_PRE_PICKUP_COLLISION", { Price = 5 }, p1); update(); update(); update()
assert(p1.coins == 3, "unaffordable touch does nothing")
p1.coins = 10; fire("MC_PRE_PICKUP_COLLISION", { Price = 3 }, p1)
update(); update(); update(); p1.coins = 7; update()
assert(p1.coins == 7, "pending purchase expires after two updates")
fire("MC_PRE_PICKUP_COLLISION", { Price = -1000 }, p1); fire("MC_PRE_PICKUP_COLLISION", { Price = 5 }, p2)
p2.coins = 0; update(); assert(p2.coins == 0, "non-holder and free/devil prices ignored")
floorSeed, stage = 8, 2; fire("MC_POST_NEW_LEVEL")
assert(p1.coins == 6, "new floor costs one coin")
fire("MC_POST_NEW_LEVEL"); assert(p1.coins == 6, "duplicate level callback does not charge twice")
p1.coins = 0; floorSeed, stage = 9, 3; fire("MC_POST_NEW_LEVEL"); assert(p1.coins == 0)
print("PASS Claudius's Discount: confirmed refund, price bounds, expiry, owner filter and floor charge")

-- One Small Rock a Day --------------------------------------------------------------
local function rock(state)
    local g = { State = state or 1 }
    function g:ToRock() return self end
    return g
end
local wall = { ToRock = function() return nil end }
grid = { [0] = rock(), [1] = wall, [2] = rock(2), [3] = rock() }
p1.trinkets[202] = true
fire("MC_POST_NEW_ROOM")
for _ = 1, 6 do update() end -- builds the watch list
for _ = 1, 6 do update() end
assert(p1.hearts == 2, "nothing broke yet; an already broken rock does not count")
p1.canHeal = false; grid[0].State = 2
for _ = 1, 6 do update() end
assert(p1.hearts == 2, "full health keeps the daily rock")
p1.canHeal = true; grid[3] = nil
for _ = 1, 6 do update() end
assert(p1.hearts == 3, "removed rock counts as broken and heals half a heart")
grid[3] = rock(); fire("MC_POST_NEW_ROOM")
for _ = 1, 6 do update() end; grid[3].State = 2; for _ = 1, 6 do update() end
assert(p1.hearts == 3, "once per floor")
-- Save/continue keeps the used flag; a new floor resets it.
local saved = Risk.state.memeExtras.players["0"].rockUsed
assert(saved == true)
floorSeed = 10; grid = { [0] = rock() }; fire("MC_POST_NEW_ROOM")
for _ = 1, 6 do update() end; grid[0].State = 2; for _ = 1, 6 do update() end
assert(p1.hearts == 4, "new floor restores the daily rock")
print("PASS One Small Rock a Day: watch list, full-health hold, once per floor, saved flag and floor reset")

-- Stuck in Mt. Moon ---------------------------------------------------------------------
p1.trinkets[203] = true
fire("MC_POST_GAME_STARTED", true) -- continue in room 10; Risk.state is the restored table
fire("MC_POST_NEW_ROOM") -- same room after continue: never counts
firstVisit = false
local function enter(i) roomIndex = i; fire("MC_POST_NEW_ROOM") end
enter(11); enter(10); enter(11); enter(10); enter(11)
assert(mapEffects == 0 and Risk.state.memeExtras.players["0"].moonVisits == 5)
firstVisit = true; enter(12); firstVisit = false
clear = false; enter(13); clear = true
fire("MC_POST_NEW_ROOM") -- duplicate callback for room 13
assert(mapEffects == 0, "first visits, uncleared rooms and duplicate callbacks do not count")
enter(10); assert(mapEffects == 1, "sixth backtrack reveals the map")
enter(11); enter(10); assert(mapEffects == 1, "once per floor")
floorSeed = 11
for i = 1, 6 do enter(20 + i % 2) end
assert(mapEffects == 2, "new floor starts a new count")
print("PASS Stuck in Mt. Moon: continue guard, eligibility, duplicate guard, once per floor and floor reset")

-- 9.11 > 9.9 --------------------------------------------------------------------------------
fire("MC_USE_PILL", 60, p2, 0)
assert(math.abs(p2.Damage - 3.61) < 1e-9, "normal pill: +0.11")
fire("MC_USE_PILL", 60, p2, 0, 3 | 2048)
assert(math.abs(p2.Damage - 4.51) < 1e-9, "horse pill: +0.9, stacking")
p1:EvaluateItems(); assert(p1.Damage == 3.5, "bonus belongs to its owner")
-- Continue: cache evaluated again from the saved table.
local savedState = Risk.state
Risk.state = { memeExtras = savedState.memeExtras }
p2.evaluated = 0; fire("MC_POST_GAME_STARTED", true)
assert(p2.evaluated == 1 and math.abs(p2.Damage - 4.51) < 1e-9 and p1.evaluated >= 1)
-- New run: Risk resets its state; no bonus.
Risk.state = {}; p2:EvaluateItems(); assert(p2.Damage == 3.5)
Risk.state = { memeExtras = { version = 1, players = { ["1"] = { decimal = "bad" } } } }
p2:EvaluateItems(); assert(p2.Damage == 3.5, "corrupt saved value is ignored")
print("PASS 9.11 > 9.9: normal/horse bonus, owner isolation, continue refresh, new run and corrupt data")
