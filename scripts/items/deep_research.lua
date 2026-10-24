-- Deep Research (active, 12 charges)
-- Parody of long-running research agents: a very long charge, then the whole
-- floor is revealed with the native map, compass and secret-room effects.
-- Car Battery does not repeat it.

local Constants = include("scripts.constants")

local Research = {}

function Research:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, _, flags)
        if (flags & UseFlag.USE_CARBATTERY) ~= 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local level = Game():GetLevel()
        level:ApplyMapEffect()
        level:ApplyCompassEffect(true)
        level:ApplyBlueMapEffect()
        Game():GetHUD():ShowItemText("Research complete", "Read 412 sources, cited 3")
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.DEEP_RESEARCH)
end

return Research
