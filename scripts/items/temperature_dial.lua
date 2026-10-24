-- Temperature Dial (active, 2 charges)
-- Sampling temperature parody. Each use toggles the holder between
-- Temperature 0 (deterministic: +10% damage, tears unchanged) and
-- Temperature 1 (creative: each fired tear gains one random native tear
-- effect from a fixed list, rolled with the item's RNG). The setting is
-- saved per player. Tears only: lasers, knives and bombs are not rolled.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Dial = {}

Dial.FLAGS = { "TEAR_HOMING", "TEAR_PIERCING", "TEAR_SPECTRAL", "TEAR_SLOW", "TEAR_POISON",
    "TEAR_FREEZE", "TEAR_CHARM", "TEAR_CONFUSION", "TEAR_WIGGLE", "TEAR_BOOMERANG" }
local COLD_DAMAGE = 1.1

local function hot(Risk, player)
    local s = MemeState.For(Risk, player)
    return s and s.temperature == 1
end

function Dial:Init(mod, Risk)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if (flags & UseFlag.USE_CARBATTERY) ~= 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local s = MemeState.For(Risk, player)
        if not s then return { Discharge = false, Remove = false, ShowAnim = false } end
        s.temperature = s.temperature == 1 and 0 or 1
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        Game():GetHUD():ShowItemText("Temperature " .. s.temperature,
            s.temperature == 1 and "Creative mode" or "Deterministic mode")
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.TEMPERATURE_DIAL)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag ~= CacheFlag.CACHE_DAMAGE or not player:HasCollectible(Constants.Item.TEMPERATURE_DIAL) then return end
        if not hot(Risk, player) then player.Damage = player.Damage * COLD_DAMAGE end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.TEMPERATURE_DIAL) then return end
        if not hot(Risk, player) then return end
        local rng = player:GetCollectibleRNG(Constants.Item.TEMPERATURE_DIAL)
        local flag = TearFlags[Dial.FLAGS[rng:RandomInt(#Dial.FLAGS) + 1]]
        if flag then tear:AddTearFlags(flag) end
    end)
end

return Dial
