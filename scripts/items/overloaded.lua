-- 529 Overloaded (trinket)
-- Every 20 seconds in an uncleared room, everything goes down: all enemies
-- freeze for 2 seconds. You're left coding manually (the "back to manual
-- coding" outage memes on X): you can still shoot, but tears deal 50% damage
-- during the outage. Meanwhile the status page insists all is operational.

local Constants = include("scripts.constants")

local Overloaded = {}

local INTERVAL = 600     -- 20 seconds
local OUTAGE_FRAMES = 60 -- 2 seconds
local MANUAL_DAMAGE = 0.5

function Overloaded:Init(mod)
    local outageUntil = 0

    -- Frame counts belong to one run; an old deadline must not penalize a new one.
    local function resetOutage()
        outageUntil = 0
    end
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, resetOutage)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, resetOutage)

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if player and Game():GetFrameCount() < outageUntil
            and player:HasTrinket(Constants.Trinket.OVERLOADED) then
            tear.CollisionDamage = tear.CollisionDamage * MANUAL_DAMAGE
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if Constants.Trinket.OVERLOADED <= 0 or Game():GetRoom():IsClear() then return end
        if Game():GetRoom():GetFrameCount() % INTERVAL ~= INTERVAL - 1 then return end

        local holder
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasTrinket(Constants.Trinket.OVERLOADED) then
                holder = player
            end
        end
        if not holder then return end

        outageUntil = Game():GetFrameCount() + OUTAGE_FRAMES
        local ref = EntityRef(holder)
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local npc = entity:ToNPC()
            if npc and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                npc:AddFreeze(ref, OUTAGE_FRAMES)
            end
        end
        Game():GetHUD():ShowItemText("529 Overloaded", "Coding manually... status page: all operational")
    end)
end

return Overloaded
