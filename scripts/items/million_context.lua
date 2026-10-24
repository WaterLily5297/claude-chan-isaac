-- 1M Context (passive)
-- Range +5, but context rot: tears lose damage the longer they fly,
-- down to 30% after 3 seconds. A Ludovico tear never stops flying, so it
-- keeps its damage instead of rotting to 30% for the rest of the run.

local Constants = include("scripts.constants")
local ThoughtAttacks = include("scripts.characters.thought_attacks")

local MillionContext = {}

local RANGE_BONUS = 5 * 40
local ROT_FRAMES = 90
local MIN_DAMAGE = 0.3

function MillionContext:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag == CacheFlag.CACHE_RANGE and player:HasCollectible(Constants.Item.MILLION_CONTEXT) then
            player.TearRange = player.TearRange + RANGE_BONUS
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.MILLION_CONTEXT) then
            return
        end
        if TearFlags.TEAR_LUDOVICO and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

        local data = tear:GetData()
        data.ccBaseDamage = data.ccBaseDamage or ThoughtAttacks.BaseDamage(tear)
        local rot = math.max(MIN_DAMAGE, 1 - tear.FrameCount / ROT_FRAMES)
        tear.CollisionDamage = data.ccBaseDamage * rot
    end)
end

return MillionContext
