-- Fixed look: mod forms clear item costumes after every costume-adding change,
-- keep item effects, ignore vanilla characters and restore costumes on leaving.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = function() return 800 end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function() return 50 end,
    GetPlayerTypeByName = function(n, tainted)
        local base = ({["Claude-chan"] = 41, ["DeepSeek-chan"] = 42, ["GPT-chan"] = 43})[n] or -1
        if base < 0 then return -1 end
        return base + (tainted and 100 or 0)
    end,
}
ModCallbacks = setmetatable({}, { __index = function(_, k) return k end })
local frame = 1
local players = {}
function Game() return {
    GetFrameCount = function() return frame end,
    GetNumPlayers = function() return #players end,
} end
function Isaac.GetPlayer(i) return players[i + 1] end
local configs = { [1] = { id = 1 }, [2] = { id = 2 }, [3] = { id = 3 } }
function Isaac.GetItemConfig() return {
    GetCollectibles = function() return { Size = 4 } end,
    GetCollectible = function(_, id) return configs[id] end,
} end

local function Player(kind)
    local p = { kind = kind, items = {}, effects = 0, trinkets = { 0, 0 }, clears = 0,
        added = {}, data = {}, Damage = 3.5 }
    function p:GetPlayerType() return self.kind end
    function p:GetData() return self.data end
    function p:GetCollectibleCount() local n = 0 for _ in pairs(self.items) do n = n + 1 end return n end
    function p:HasCollectible(id) return self.items[id] == true end
    function p:GetTrinket(slot) return self.trinkets[slot + 1] end
    function p:GetEffects()
        local owner = self
        return { GetEffectsList = function() return { Size = owner.effects } end }
    end
    function p:ClearCostumes() self.clears = self.clears + 1 end
    function p:AddCostume(item) self.added[#self.added + 1] = item.id end
    return p
end

local callbacks = {}
local mod = { AddCallback = function(_, id, fn) callbacks[id] = fn end }
local Lock = include("scripts.characters.costume_lock")
Lock:Init(mod)
local function Tick(p) callbacks.MC_POST_PLAYER_UPDATE(nil, p); frame = frame + 1 end
local function Settle(p) frame = 1; for _ = 1, Lock.SETTLE_FRAMES + 2 do Tick(p) end end

-- Every registered mod form is locked, normal and tainted; vanilla is not.
for _, id in ipairs({ 41, 42, 43, 141, 142, 143 }) do
    assert(Lock:IsLocked(Player(id)), "form " .. id .. " keeps its own look")
end
assert(not Lock:IsLocked(Player(0)), "vanilla Isaac keeps item costumes")

-- First update clears for the settle window, then stays quiet off-sweep.
local claude = Player(41)
players = { claude }
frame = 1
Settle(claude)
assert(claude.clears == Lock.SETTLE_FRAMES, "initial costumes cleared while settling")
local before = claude.clears

-- A pickup clears costumes; the item itself (and its stats) stay.
claude.items[2] = true
Settle(claude)
assert(claude.clears == before + Lock.SETTLE_FRAMES, "pickup costume cleared")
assert(claude.items[2] and claude.Damage == 3.5, "item and stats untouched")

-- Temporary effects, trinkets, uses and new rooms all trigger a clear.
for _, change in ipairs({
    function() claude.effects = 1 end,
    function() claude.trinkets[1] = 190 end,
    function() callbacks.MC_USE_ITEM(nil, 1, nil, claude) end,
    function() callbacks.MC_USE_CARD(nil, 1, claude) end,
    function() callbacks.MC_USE_PILL(nil, 1, claude) end,
    function() callbacks.MC_POST_NEW_ROOM() end,
    function() callbacks.MC_POST_GAME_STARTED(nil, true) end,
}) do
    before = claude.clears
    change()
    Settle(claude)
    assert(claude.clears == before + Lock.SETTLE_FRAMES, "costume-adding change cleared")
end

-- The slow sweep catches item-state costumes without a signature change.
before = claude.clears
frame = Lock.SWEEP_FRAMES * 10
Tick(claude)
assert(claude.clears == before + 1, "sweep clears stragglers")

-- Vanilla players are never touched, even when marked by a room change.
local isaac = Player(0)
isaac.items[1] = true
players = { claude, isaac }
callbacks.MC_POST_NEW_ROOM()
Settle(isaac)
assert(isaac.clears == 0 and #isaac.added == 0, "vanilla character untouched")

-- Leaving a mod form (Clicker) restores held item costumes once.
claude.items = { [1] = true, [3] = true }
claude.kind = 0
Tick(claude); Tick(claude)
table.sort(claude.added)
assert(#claude.added == 2 and claude.added[1] == 1 and claude.added[2] == 3,
    "held item costumes restored after leaving the form")

-- Lock state is transient: nothing is written outside GetData.
assert(next(isaac.data) == nil or isaac.data.ccCostumeSig == nil)
print("OK: mod forms keep their own look while items keep their effects")
