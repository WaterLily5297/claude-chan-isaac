-- Six Seven: one seeded roll, six or seven native blue flies for the user.
-- Every pill size uses the same roll. No optional pill-color argument is needed.
local Constants = include("scripts.constants")
local SixSeven = {}

function SixSeven:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect, player, flags)
        local count = 6 + player:GetPillRNG(effect):RandomInt(2)
        -- Fish Tail and other native fly behavior belong to AddBlueFlies.
        player:AddBlueFlies(count, player.Position, nil)
        if ((flags or 0) & UseFlag.USE_NOHUD) == 0 then
            Game():GetHUD():ShowItemText("Six Seven", tostring(count) .. ". Final answer.")
        end
    end, Constants.Pill.SIX_SEVEN)
end

return SixSeven
