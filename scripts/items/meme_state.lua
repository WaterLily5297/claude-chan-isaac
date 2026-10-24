-- Saved per-player state shared by the meme extras (trinkets and pill).
-- Lives in Risk.state.memeExtras, so it is written with the normal save,
-- restored on continue and dropped on a new run. Keyed by player slot;
-- no entity references are stored.

local MemeState = {}

local VERSION = 1

function MemeState.FloorKey()
    local level = Game():GetLevel()
    return tostring(level:GetDungeonPlacementSeed()) .. ":" .. level:GetStage() .. ":" .. level:GetStageType()
end

local function slot(player)
    local hash = GetPtrHash(player)
    for i = 0, Game():GetNumPlayers() - 1 do
        if GetPtrHash(Isaac.GetPlayer(i)) == hash then return tostring(i) end
    end
end

local function number(v, default)
    return (type(v) == "number" and v == v and v >= 0 and v < 1e6) and v or default
end

-- Returns the player's table, with floor-scoped fields reset on a new floor.
function MemeState.For(Risk, player)
    local key = slot(player)
    if not key then return nil end
    local all = Risk.state.memeExtras
    if type(all) ~= "table" or all.version ~= VERSION or type(all.players) ~= "table" then
        all = { version = VERSION, players = {} }
        Risk.state.memeExtras = all
    end
    local s = all.players[key]
    if type(s) ~= "table" then s = {}; all.players[key] = s end
    s.decimal = number(s.decimal, 0)
    s.temperature = s.temperature == 1 and 1 or 0
    local floor = MemeState.FloorKey()
    if s.floor ~= floor then
        s.floor, s.rockUsed, s.moonVisits, s.moonDone = floor, false, 0, false
    end
    s.moonVisits = math.floor(number(s.moonVisits, 0))
    s.rockUsed, s.moonDone = s.rockUsed == true, s.moonDone == true
    return s
end

-- Saved run-wide damage bonus without creating or rewriting any state.
function MemeState.Decimal(Risk, player)
    local all = Risk.state.memeExtras
    if type(all) ~= "table" or all.version ~= VERSION or type(all.players) ~= "table" then return 0 end
    local key = slot(player)
    local s = key and all.players[key]
    return type(s) == "table" and number(s.decimal, 0) or 0
end

function MemeState.Holders(trinket)
    local list = {}
    if trinket <= 0 then return list end
    for i = 0, Game():GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)
        if p:HasTrinket(trinket) then list[#list + 1] = p end
    end
    return list
end

return MemeState
