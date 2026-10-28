-- Keeps saved per-slot item state with the live player who earned it.
--
-- The backlog and meme maps are keyed by player slot, because pointers and
-- entity data do not survive Continue. Within a session each slot's live
-- pointer and InitSeed are remembered here, never saved. When a slot changes
-- owner, its table is parked under the old identity, and the new owner gets
-- the table parked under its own identity, or none. So a reordered player
-- keeps its own progress, a replacement entity starts fresh, and a removed
-- player's table cannot reach a later join. The first observation after a
-- reset, or of a new saved map, binds the saved slots as they are: that is
-- how Continue restores them to the recreated players.

local SlotOwners = {}
SlotOwners.__index = SlotOwners

function SlotOwners.New()
    local self = setmetatable({}, SlotOwners)
    self:Reset()
    return self
end

function SlotOwners:Reset()
    self.map, self.bound, self.owners, self.parked, self.moved = nil, false, {}, {}, {}
end

local function identity(player)
    return tostring(GetPtrHash(player)) .. ":" .. tostring(player.InitSeed)
end

-- Reconcile `players` (slot key -> saved table) with the live slots.
function SlotOwners:Observe(players)
    if self.map ~= players then self:Reset(); self.map = players end
    local count, owners, parked = Game():GetNumPlayers(), self.owners, self.parked
    for key, id in pairs(owners) do
        local i = tonumber(key)
        local p = i < count and Isaac.GetPlayer(i)
        if not p or identity(p) ~= id then
            if players[key] ~= nil then parked[id] = players[key] end
            players[key], owners[key] = nil, nil
        end
    end
    for i = 0, count - 1 do
        local key = tostring(i)
        if not owners[key] then
            local id = identity(Isaac.GetPlayer(i))
            if self.bound then
                players[key], parked[id] = parked[id], nil
                self.moved[key] = true
            end
            owners[key] = id
        end
    end
    self.bound = true
end

-- Slot keys whose table changed since the last call, for cache refreshes.
function SlotOwners:TakeMoved()
    local moved = self.moved
    self.moved = {}
    return moved
end

return SlotOwners
