-- Lunch Break (active, 6 charges) - DeepSeek-chan's pocket item
-- DeepSeek's "brb, getting food" community joke.
-- Heals one red heart and puts the whole room on break: every enemy is slowed
-- for 3 seconds. A shared saved timer suppresses new directional shooting input.

local Constants = include("scripts.constants")

local LunchBreak = {}

local HEAL = 2                 -- half hearts
local BREAK_FRAMES = 90        -- 3 s
local SLOW = 0.5
local SLOW_COLOR = Color(0.8, 0.9, 1, 1, 0, 0, 0)

function LunchBreak:Init(mod, MealBreak)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if ((flags or 0) & UseFlag.USE_CARBATTERY) ~= 0 or MealBreak:Remaining(player) > 0 then
            return {Discharge = false, Remove = false, ShowAnim = false}
        end
        if not MealBreak:Start(player, BREAK_FRAMES) then
            return {Discharge = false, Remove = false, ShowAnim = false}
        end
        player:AddHearts(HEAL)

        local ref = EntityRef(player)
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local npc = entity:ToNPC()
            if npc and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                npc:AddSlowing(ref, BREAK_FRAMES, SLOW, SLOW_COLOR)
            end
        end

        Game():GetHUD():ShowItemText("Brb, getting food", "Everyone's on lunch break")
        return {Discharge = true, Remove = false, ShowAnim = true}
    end, Constants.Item.LUNCH_BREAK)
end

return LunchBreak
