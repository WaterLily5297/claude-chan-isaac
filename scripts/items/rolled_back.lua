-- Rolled Back (pill)
-- Parody of the 2025 "too flattering" update that was rolled back: all
-- stats up for the current room (damage +1, shot interval x0.8, speed +0.2,
-- range +40, shot speed +0.1, luck +1; doubled for a horse pill when the
-- game passes the pill color), then the next room rolls it back.

local Constants = include("scripts.constants")
local FireRate = include("scripts.fire_rate")

local RolledBack = {}

local function refresh(player)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED
        | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK)
    player:EvaluateItems()
end

function RolledBack:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player, _, color)
        local horse = type(color) == "number" and PillColor and PillColor.PILL_GIANT_FLAG
            and (color & PillColor.PILL_GIANT_FLAG) ~= 0
        local data = player:GetData()
        data.ccRolledBack = math.min(2, (data.ccRolledBack or 0) + (horse and 2 or 1))
        refresh(player)
        Game():GetHUD():ShowItemText("What a brilliant run!", "Truly visionary. (Until the next room)")
    end, Constants.Pill.ROLLED_BACK)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:GetData().ccRolledBack then
                player:GetData().ccRolledBack = nil
                refresh(player)
                Game():GetHUD():ShowItemText("Update rolled back", "")
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        local n = player:GetData().ccRolledBack
        if not n then return end
        if flag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage + n
        elseif flag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = FireRate.ScaleInterval(player.MaxFireDelay, 0.8 ^ n)
        elseif flag == CacheFlag.CACHE_SPEED then player.MoveSpeed = player.MoveSpeed + 0.2 * n
        elseif flag == CacheFlag.CACHE_RANGE then player.TearRange = player.TearRange + 40 * n
        elseif flag == CacheFlag.CACHE_SHOTSPEED then player.ShotSpeed = player.ShotSpeed + 0.1 * n
        elseif flag == CacheFlag.CACHE_LUCK then player.Luck = player.Luck + n
        end
    end)
end

return RolledBack
