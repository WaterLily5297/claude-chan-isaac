-- Shared DeepSeek stats/pocket and legacy tainted forks.
-- Normal Rice First is implemented in deepseek_rice.lua.
-- Tainted Peak / Valley is still pending; do not describe it as implemented.
-- Art attribution and license: resources/ART_LICENSE.md.

local Constants = include("scripts.constants")
local HudText = include("scripts.hud_text")
local TearFork = include("scripts.tear_fork")

local DeepSeek = {}

local NORMAL_DAMAGE = 0.9
local TAINTED_DAMAGE = 0.8
local FORK_SPREAD = 12
local FORK_DAMAGE = 0.5
local BUSY = { per = 0.05, max = 0.4 }
local MESSAGE_FRAMES = 60
local NORMAL_COLOR = Color(0.35, 0.65, 1, 1, 0, 0, 0)
local TAINTED_COLOR = Color(0.45, 1, 0.95, 1, 0, 0, 0)

local function kind(player)
    local t = player:GetPlayerType()
    if Constants.Player.DEEPSEEK_CHAN >= 0 and t == Constants.Player.DEEPSEEK_CHAN then return "normal" end
    if Constants.Player.DEEPSEEK_CHAN_B >= 0 and t == Constants.Player.DEEPSEEK_CHAN_B then return "tainted" end
end

local function state(player)
    local data = player:GetData()
    if not data.ccDeepSeek then
        data.ccDeepSeek = { message = nil, messageUntil = 0 }
    end
    return data.ccDeepSeek
end

local function say(s, key, value)
    s.message, s.value, s.messageUntil = key, value, Game():GetFrameCount() + MESSAGE_FRAMES
end

function DeepSeek:Init(mod)
    local rng = RNG()

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        rng:SetSeed(math.max(1, Game():GetSeeds():GetStartSeed() + 2025), 35)
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

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        local k = player and kind(player)
        if k ~= "tainted" then return end
        local s = state(player)

        -- Legacy tainted congestion, pending its deliberate Peak / Valley migration.
        local busy = BUSY
        if rng:RandomFloat() < math.min(busy.max, Isaac.CountEnemies() * busy.per) then
            tear:Remove()
            say(s, "busy")
            return
        end

        for _, angle in ipairs({ -FORK_SPREAD, FORK_SPREAD }) do
            local fork = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, 0, tear.Position,
                tear.Velocity:Rotated(angle), player):ToTear()
            if fork then
                TearFork.Copy(tear, fork, FORK_DAMAGE)
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not Game():GetHUD():IsVisible() then return end
        local now = Game():GetFrameCount()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            local s = kind(player) == "tainted" and player:GetData().ccDeepSeek
            if s and s.message and now < s.messageUntil then
                local y = Isaac.GetScreenHeight() - 40 - i * 12
                local text = s.message == "thought" and HudText:T("thought", s.value) or HudText:T(s.message)
                HudText:Draw(text, 50, y, 0.45, 0.75, 1, 1)
            end
        end
    end)
end

return DeepSeek
