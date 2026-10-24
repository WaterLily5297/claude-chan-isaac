-- Blueberry (passive)
-- Parody of a model confidently counting three B's in "blueberry": every
-- third tear a player fires is a blue "B" tear that splits on impact. It
-- promises three pieces and, counting is hard, the native split makes four.
-- The count is per player and per tear, separate from Strawberry's.
-- Tears only: lasers, knives and bombs are not counted.

local Constants = include("scripts.constants")

local Blueberry = {}

Blueberry.EVERY = 3

function Blueberry:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.BLUEBERRY) then return end
        local data = player:GetData()
        data.ccBlueberry = ((data.ccBlueberry or 0) + 1) % Blueberry.EVERY
        if data.ccBlueberry ~= 0 then return end
        tear:AddTearFlags(TearFlags.TEAR_QUADSPLIT)
        local c = tear.Color
        tear.Color = Color(c.R * 0.45, c.G * 0.55, c.B, c.A, c.RO, c.GO, c.BO + 0.25)
    end)
end

return Blueberry
