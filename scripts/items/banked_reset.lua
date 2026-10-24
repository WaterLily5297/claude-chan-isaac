-- Banked Reset (active, 12 charges)
-- A rate-limit reset you can save and use whenever you choose: clears
-- Claude-chan's usage meter (ending a usage limit early), refills Tainted
-- Claude-chan's Quota (cancelling a pending review without returning its
-- Page), and lowers your risk score by 25.

local Constants = include("scripts.constants")
local TaintedClaude = include("scripts.characters.claude_chan_b")

local BankedReset = {}

local RISK_REDUCTION = 25

function BankedReset:Init(mod, Risk)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
        local usage = player:GetData().ccUsage
        if usage then
            usage.value = 0
            usage.limited = 0
        end
        TaintedClaude.Refill(Risk, player)
        Risk:Add(-RISK_REDUCTION)

        Game():GetHUD():ShowItemText("Limits reset", "Thanks for your patience")
        return true
    end, Constants.Item.BANKED_RESET)
end

return BankedReset
