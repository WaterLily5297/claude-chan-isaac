-- Shared DeepSeek stats and pocket item.
-- Normal Rice First is in deepseek_rice.lua; tainted Peak / Valley is in deepseek_peak.lua.
-- Art attribution and license: resources/ART_LICENSE.md.

local Constants = include("scripts.constants")

local DeepSeek = {}

local NORMAL_DAMAGE = 0.9
local TAINTED_DAMAGE = 0.8
local NORMAL_COLOR = Color(0.35, 0.65, 1, 1, 0, 0, 0)
local TAINTED_COLOR = Color(0.45, 1, 0.95, 1, 0, 0, 0)

local function kind(player)
    local t = player:GetPlayerType()
    if Constants.Player.DEEPSEEK_CHAN >= 0 and t == Constants.Player.DEEPSEEK_CHAN then return "normal" end
    if Constants.Player.DEEPSEEK_CHAN_B >= 0 and t == Constants.Player.DEEPSEEK_CHAN_B then return "tainted" end
end

function DeepSeek:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        if continued or Constants.Item.LUNCH_BREAK <= 0 then return end
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if kind(player) == "normal" then
                player:SetPocketActiveItem(Constants.Item.LUNCH_BREAK, ActiveSlot.SLOT_POCKET, false)
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        local k = kind(player)
        if not k then return end
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * (k == "normal" and NORMAL_DAMAGE or TAINTED_DAMAGE)
        elseif flag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = k == "normal" and NORMAL_COLOR or TAINTED_COLOR
        end
    end)
end

return DeepSeek
