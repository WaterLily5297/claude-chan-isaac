-- Pizza Glue (passive)
-- Search-summary parody ("add glue to the sauce"): 25% of fired tears are
-- sticky and gain the native slowing flag (+2.5% per luck, 10% to 50%).
-- -0.1 shot speed per copy. Tear-only: lasers, knives and bombs are not
-- rolled. The roll uses the item's native per-player RNG, so it needs no
-- saved state and is never reseeded on continue.

local Constants = include("scripts.constants")

local Glue = {}

local BASE, PER_LUCK, MIN_CHANCE, MAX_CHANCE = 0.25, 0.025, 0.10, 0.50
local SHOT_SPEED = 0.1

function Glue.Chance(luck)
    return math.max(MIN_CHANCE, math.min(MAX_CHANCE, BASE + PER_LUCK * (luck or 0)))
end

function Glue:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag ~= CacheFlag.CACHE_SHOTSPEED or not player:HasCollectible(Constants.Item.PIZZA_GLUE) then return end
        player.ShotSpeed = player.ShotSpeed - SHOT_SPEED * player:GetCollectibleNum(Constants.Item.PIZZA_GLUE)
    end)

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.PIZZA_GLUE) then return end
        if tear:HasTearFlags(TearFlags.TEAR_SLOW) then return end
        local rng = player:GetCollectibleRNG(Constants.Item.PIZZA_GLUE)
        if rng:RandomFloat() >= Glue.Chance(player.Luck) then return end
        tear:AddTearFlags(TearFlags.TEAR_SLOW)
        -- Glaze over the native color so Ipecac, Spoon Bender or a form tint stays readable.
        local c = tear.Color
        if c then tear.Color = Color(c.R, c.G, c.B * 0.85, c.A, c.RO + 0.25, c.GO + 0.22, c.BO + 0.12)
        else tear.Color = Color(1, 1, 0.85, 1, 0.25, 0.22, 0.12) end
    end)
end

return Glue
