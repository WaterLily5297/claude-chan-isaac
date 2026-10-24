-- Golden Gate Claude (passive)
-- Parody of the feature-steering demo that could not stop talking about the
-- Golden Gate Bridge: tears gain the native spectral flag (they pass over
-- rocks like a bridge), +1.5 range and a golden tint. Entering a new hostile
-- room sometimes brings the bridge up again, as a caption only.

local Constants = include("scripts.constants")

local GoldenGate = {}

local RANGE, CAPTION_CHANCE = 60, 0.25

function GoldenGate:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not player:HasCollectible(Constants.Item.GOLDEN_GATE) then return end
        if flag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + RANGE * player:GetCollectibleNum(Constants.Item.GOLDEN_GATE)
        elseif flag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
        elseif flag == CacheFlag.CACHE_TEARCOLOR then
            -- Tint rather than replace, so other item colors stay readable.
            local c = player.TearColor
            if c then player.TearColor = Color(c.R, c.G * 0.9, c.B * 0.5, c.A, c.RO + 0.25, c.GO + 0.18, c.BO)
            else player.TearColor = Color(1, 0.9, 0.5, 1, 0.25, 0.18, 0) end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        local room = Game():GetRoom()
        if room:IsClear() or not room:IsFirstVisit() then return end
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasCollectible(Constants.Item.GOLDEN_GATE) then
                local rng = player:GetCollectibleRNG(Constants.Item.GOLDEN_GATE)
                if rng:RandomFloat() < CAPTION_CHANCE then
                    Game():GetHUD():ShowItemText("I am the Golden Gate Bridge", "This room reminds me of a bridge")
                end
                return
            end
        end
    end)
end

return GoldenGate
