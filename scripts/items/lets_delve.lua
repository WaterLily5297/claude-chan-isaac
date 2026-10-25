-- Let's Delve: let the native shovel decide what can be dug here.
-- The wrapper owns its charge/animation; the nested effect owns no active slot.
local Constants = include("scripts.constants")
local Delve = {}

function Delve:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        flags = flags or 0
        if (flags & UseFlag.USE_CARBATTERY) ~= 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local nestedFlags = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME
            | UseFlag.USE_ALLOWNONMAIN | UseFlag.USE_MIMIC | (flags & UseFlag.USE_NOHUD)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, nestedFlags, -1)
        if (flags & UseFlag.USE_NOHUD) == 0 then
            Game():GetHUD():ShowItemText("Let's Delve", "A deeper understanding")
        end
        -- The API returns no native success flag. A use spends the charge even
        -- where the shovel cannot dig; never fabricate a floor exit or refund.
        return { Discharge = true, Remove = false, ShowAnim = (flags & UseFlag.USE_NOANIM) == 0 }
    end, Constants.Item.LETS_DELVE)
end

return Delve
