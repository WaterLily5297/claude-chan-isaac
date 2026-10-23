-- Pills based on DeepSeek-chan memes (design by 上善无形 / ZipZipPipe).
--
-- Cat-girl Mode: for the rest of the room, tears fire twice as fast but deal
--   60% damage. Nya.
-- Brb, Getting Food: heals one red heart, but you stop shooting for 3 seconds.

local Constants = include("scripts.constants")

local Pills = {}

local CAT_FIRE_DELAY_MULT = 0.5
local CAT_DAMAGE_MULT = 0.6
local FOOD_HEAL = 2          -- half hearts
local FOOD_BREAK_FRAMES = 90 -- 3 seconds

local function refresh(player)
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
end

function Pills:Init(mod, MealBreak)
    mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player)
        player:GetData().ccCatGirl = true
        refresh(player)
        Game():GetHUD():ShowItemText("Cat-girl Mode", "Nya~")
    end, Constants.Pill.CAT_GIRL)

    mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player)
        if not MealBreak:Start(player, FOOD_BREAK_FRAMES) then return end
        player:AddHearts(FOOD_HEAL)
        Game():GetHUD():ShowItemText("Brb, getting food", "")
    end, Constants.Pill.GETTING_FOOD)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:GetData().ccCatGirl then
                player:GetData().ccCatGirl = nil
                refresh(player)
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not player:GetData().ccCatGirl then return end

        if flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay * CAT_FIRE_DELAY_MULT
        elseif flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * CAT_DAMAGE_MULT
        end
    end)
end

return Pills
