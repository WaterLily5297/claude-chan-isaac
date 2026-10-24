-- "Agentic" transformation
-- Like Isaac's own transformations (Guppy, Beelzebub...): hold any 3 of the
-- Claude Code items below and you go fully agentic: flight, tears up
-- (shot interval x0.8) and +0.5 damage.

local Constants = include("scripts.constants")
local FireRate = include("scripts.fire_rate")

local Transformation = {}

local REQUIRED = 3
local FIRE_DELAY_MULT = 0.8
local DAMAGE_BONUS = 0.5

local SET = {
    Constants.Item.ULTRATHINK,
    Constants.Item.COMPACT,
    Constants.Item.VIBE_CODING,
    Constants.Item.SUBAGENT_SWARM,
    Constants.Item.SKIP_PERMISSIONS,
    Constants.Item.TESTS_PASSING,
}

local function countSet(player)
    local n = 0
    for _, item in ipairs(SET) do
        if item > 0 and player:HasCollectible(item) then
            n = n + 1
        end
    end
    return n
end

function Transformation:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
        local data = player:GetData()
        local agentic = countSet(player) >= REQUIRED
        if agentic == (data.ccAgentic == true) then return end

        data.ccAgentic = agentic
        player:AddCacheFlags(CacheFlag.CACHE_FLYING | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        if agentic then
            Game():GetHUD():ShowItemText("Agentic!", "")
            SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not player:GetData().ccAgentic then return end

        if flag == CacheFlag.CACHE_FLYING then
            player.CanFly = true
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = FireRate.ScaleInterval(player.MaxFireDelay, FIRE_DELAY_MULT)
        elseif flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + DAMAGE_BONUS
        end
    end)
end

return Transformation
