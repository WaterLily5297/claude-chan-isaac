-- Thinking Cleared (trinket)
-- Based on the reported cache bug that wiped the thinking every turn: Claude
-- kept working, but forgot why. Each room you enter for the first time drains
-- one charge from your active item, but you get +1 damage while you hold it:
-- still working, no idea why. Revisiting cleared rooms costs nothing.

local Constants = include("scripts.constants")

local ThinkingCleared = {}

local ROOM_DAMAGE = 1

local function refreshHeldDamage(player)
    local data = player:GetData()
    local holds = player:HasTrinket(Constants.Trinket.THINKING_CLEARED)
    if holds ~= (data.ccThinkingCleared == true) then
        -- This transient marker only schedules a refresh; inventory owns the bonus.
        data.ccThinkingCleared = holds
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end

function ThinkingCleared:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        local firstVisit = Game():GetRoom():IsFirstVisit()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            local holds = player:HasTrinket(Constants.Trinket.THINKING_CLEARED)

            if holds and firstVisit then
                local charge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
                if charge > 0 then
                    player:SetActiveCharge(charge - 1, ActiveSlot.SLOT_PRIMARY)
                end
            end

            refreshHeldDamage(player)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
        refreshHeldDamage(player)
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag == CacheFlag.CACHE_DAMAGE
            and player:HasTrinket(Constants.Trinket.THINKING_CLEARED) then
            player.Damage = player.Damage + ROOM_DAMAGE
        end
    end)
end

return ThinkingCleared
