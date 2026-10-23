-- Subagent Swarm (passive, devil pool)
-- Every tear spawns two parallel subagent tears at ±15° that deal 50% damage.
-- For Claude-chan, the subagents burn usage too: each tear costs double.

local Constants = include("scripts.constants")
local TearFork = include("scripts.tear_fork")

local SubagentSwarm = {}

local SPREAD = 15
local SUBAGENT_DAMAGE = 0.5

function SubagentSwarm:Init(mod)
    -- Keep billing before Claude's normal shot accounting and limit checks.
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.SUBAGENT_SWARM) then
            return
        end

        local usage = player:GetData().ccUsage
        if usage and usage.limited == 0 and player:GetPlayerType() == Constants.Player.CLAUDE_CHAN then
            usage.value = math.min(100, usage.value + 4)
        end
    end)

    -- Resolve cancellation, character limits and damage modifiers before copying.
    mod:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TEAR, CallbackPriority.LATE, function(_, tear)
        if not tear:Exists() then return end
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.SUBAGENT_SWARM) then
            return
        end

        for _, angle in ipairs({ -SPREAD, SPREAD }) do
            local sub = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, 0, tear.Position,
                tear.Velocity:Rotated(angle), player):ToTear()
            if sub then
                TearFork.Copy(tear, sub, SUBAGENT_DAMAGE)
            end
        end
    end)
end

return SubagentSwarm
