-- 9.11 > 9.9 (pill)
-- Parody of models insisting 9.11 is bigger than 9.9: the pill picks the
-- "bigger" bonus, a permanent +0.11 damage. A horse pill picks +0.9 instead.
-- The bonus is saved per player and re-applied after continue.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Decimal = {}

Decimal.SMALL, Decimal.HORSE = 0.11, 0.9

local function refresh(player)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
end

function Decimal:Init(mod, Risk)
    mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player, _, color)
        -- The pill color argument is absent on some game versions.
        local horse = type(color) == "number" and PillColor and PillColor.PILL_GIANT_FLAG
            and (color & PillColor.PILL_GIANT_FLAG) ~= 0
        local s = MemeState.For(Risk, player)
        if not s then return end
        local bonus = horse and Decimal.HORSE or Decimal.SMALL
        s.decimal = s.decimal + bonus
        refresh(player)
        Game():GetHUD():ShowItemText("9.11 > 9.9", string.format("Damage +%.2f, obviously the bigger one", bonus))
    end, Constants.Pill.DECIMAL)

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if MemeState.Decimal(Risk, player) > 0 then refresh(player) end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag ~= CacheFlag.CACHE_DAMAGE then return end
        local bonus = MemeState.Decimal(Risk, player)
        if bonus > 0 then player.Damage = player.Damage + bonus end
    end)
end

return Decimal
