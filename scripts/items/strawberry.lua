-- Strawberry (passive)
-- Parody of "how many R's are in strawberry?": every third tear a player
-- fires is a red "R" tear with 2x damage and a slightly larger size. The
-- count is per player and per tear, so multi-shot volleys advance it once per
-- tear. The multiplier scales whatever damage the tear already has.
-- Tears only: lasers, knives and bombs are not counted.

local Constants = include("scripts.constants")

local Strawberry = {}

Strawberry.EVERY, Strawberry.DAMAGE = 3, 2

function Strawberry:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.STRAWBERRY) then return end
        local data = player:GetData()
        data.ccStrawberry = ((data.ccStrawberry or 0) + 1) % Strawberry.EVERY
        if data.ccStrawberry ~= 0 then return end
        tear.CollisionDamage = tear.CollisionDamage * Strawberry.DAMAGE
        tear.Scale = tear.Scale * 1.2
        local c = tear.Color
        tear.Color = Color(c.R, c.G * 0.35, c.B * 0.35, c.A, c.RO + 0.3, c.GO, c.BO)
    end)
end

return Strawberry
