-- Compact (active, 3 charges)
-- "Compacting conversation...": removes every enemy projectile in the room and
-- makes all enemies forget what they were doing (confused for 3 seconds).
-- For Claude-chan, compacting reloads the whole context and costs 50 usage,
-- a nod to the "compacting ate my entire 5-hour limit" complaints. Reaching
-- 100 this way starts Limited at once, like any other paid action.

local Constants = include("scripts.constants")

local Compact = {}

local CONFUSE_FRAMES = 90
local CLAUDE_USAGE_COST = 50
local USAGE_MAX = 100
local LIMIT_FRAMES = 150 -- same as scripts/characters/claude_chan.lua

function Compact:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        local ref = EntityRef(player)

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_PROJECTILE then
                entity:Remove()
            else
                local npc = entity:ToNPC()
                if npc and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                    npc:AddConfusion(ref, CONFUSE_FRAMES, false)
                end
            end
        end

        -- Car Battery repeats the effect, not the bill: one use costs 50 once.
        local battery = UseFlag and UseFlag.USE_CARBATTERY and ((flags or 0) & UseFlag.USE_CARBATTERY) ~= 0
        local usage = player:GetData().ccUsage
        local limited = false
        if usage and not battery and player:GetPlayerType() == Constants.Player.CLAUDE_CHAN and usage.limited == 0 then
            usage.value = math.min(USAGE_MAX, usage.value + CLAUDE_USAGE_COST)
            if usage.value >= USAGE_MAX then
                -- The character module applies the damage penalty on its next update.
                usage.limited, limited = LIMIT_FRAMES, true
            end
        end

        if limited then
            Game():GetHUD():ShowItemText("Usage limit reached", "Compacting used up the rest")
        else
            Game():GetHUD():ShowItemText("Compacting conversation...", "Enemies forgot what they were doing")
        end
        return true
    end, Constants.Item.COMPACT)
end

return Compact
