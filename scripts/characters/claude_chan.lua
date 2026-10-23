-- Claude-chan (playable character)
-- Character design by ZipZipPipe (Bilibili / Pixiv), used non-commercially with credit.
--
-- Stats: long context window (Range +1.5), Shot Speed +0.2, Speed -0.1, orange tears.
-- Pocket item: Ban Hammer.
-- Usage limit: every tear fills a usage meter that drains slowly over time.
-- When it fills up she hits her usage limit: for 5 seconds her tears deal
-- 40% damage, then the meter resets.
-- Account age (账号满月): every floor she reaches without being Suspended, her
-- account gets a floor older: +0.2 damage each, up to +1.6. Getting
-- Suspended resets it to zero ("Banned again" / 又封了). Based on the
-- "喜报：Claude满月啦" posts and the Bilibili song 《又封了》.

local Constants = include("scripts.constants")
local HudText = include("scripts.hud_text")

local ClaudeChan = {}

local USAGE_MAX = 100
local USAGE_PER_TEAR = 4
local USAGE_DRAIN_INTERVAL = 6      -- frames per point drained (5 points/second)
local LIMIT_FRAMES = 150            -- 5 seconds
local LIMITED_DAMAGE_MULT = 0.4

local AGE_DAMAGE = 0.2
local AGE_MAX = 8

local TEAR_COLOR = Color(1, 0.55, 0.25, 1, 0, 0, 0)
local LIMITED_TEAR_COLOR = Color(0.5, 0.5, 0.5, 0.7, 0, 0, 0)

local function isClaude(player)
    return player and Constants.Player.CLAUDE_CHAN >= 0
        and player:GetPlayerType() == Constants.Player.CLAUDE_CHAN
end

local function anyClaude()
    for i = 0, Game():GetNumPlayers() - 1 do
        if isClaude(Isaac.GetPlayer(i)) then return true end
    end
    return false
end

local function refreshDamage()
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if isClaude(player) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end
end

function ClaudeChan:Init(mod, Risk)
    local ready = false
    local function age() return Risk.state.accountAge or 0 end

    local function getUsage(player)
        local data = player:GetData()
        for i = 0, Game():GetNumPlayers() - 1 do
            if GetPtrHash(Isaac.GetPlayer(i)) == GetPtrHash(player) then
                -- Slots survive continue; pointers and entity data do not.
                local all = Risk.state.claudeUsage
                if type(all) ~= "table" then all = {}; Risk.state.claudeUsage = all end
                local key = tostring(i)
                if type(all[key]) ~= "table" then
                    all[key] = { value = 0, limited = 0 }
                end
                -- Compact, Banked Reset and Swarm mutate this same saved table.
                data.ccUsage = all[key]
                return all[key]
            end
        end
        -- An entity outside the player list must not borrow another player's slot.
        data.ccUsage = data.ccUsage or { value = 0, limited = 0 }
        return data.ccUsage
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        -- Risk has already loaded or reset its state, before any item use or shot.
        if not continued then Risk.state.claudeUsage = {} end
        ready = true
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if isClaude(player) then getUsage(player) end
        end
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() ready = false end)

    -- POST_NEW_LEVEL also fires before the run starts; only count real floors.
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        if not ready or not anyClaude() or Risk:IsSuspended() then return end
        Risk.state.accountAge = math.min(AGE_MAX, age() + 1)
        refreshDamage()
    end)

    -- Give the Ban Hammer as a pocket active on a fresh run only, so continuing
    -- a run doesn't reset its charge.
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
        if isContinued or Constants.Item.BAN_HAMMER <= 0 then return end

        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if isClaude(player) then
                player:SetPocketActiveItem(Constants.Item.BAN_HAMMER, ActiveSlot.SLOT_POCKET, false)
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not isClaude(player) then return end

        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + AGE_DAMAGE * age()
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + 1.5 * 40
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.2
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed - 0.1
        elseif flag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = TEAR_COLOR
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        if not ready then return end
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if not isClaude(player) then return end

        local usage = getUsage(player)
        if usage.limited > 0 then
            tear.CollisionDamage = tear.CollisionDamage * LIMITED_DAMAGE_MULT
            tear.Color = LIMITED_TEAR_COLOR
            return
        end

        usage.value = usage.value + USAGE_PER_TEAR
        if usage.value >= USAGE_MAX then
            usage.value = USAGE_MAX
            usage.limited = LIMIT_FRAMES
            Game():GetHUD():ShowItemText("Usage limit reached", "Your limit will reset soon")
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
        if not ready then return end
        if not isClaude(player) then return end

        if age() > 0 and Risk:IsSuspended() then
            Risk.state.accountAge = 0
            refreshDamage()
            Game():GetHUD():ShowItemText("Banned again", "Account age reset to 0")
        end

        local usage = getUsage(player)
        if usage.limited > 0 then
            usage.limited = usage.limited - 1
            if usage.limited == 0 then
                usage.value = 0
            end
        elseif usage.value > 0 and Game():GetFrameCount() % USAGE_DRAIN_INTERVAL == 0 then
            usage.value = usage.value - 1
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready or not Game():GetHUD():IsVisible() then return end

        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if isClaude(player) then
                local usage = getUsage(player)
                local y = Isaac.GetScreenHeight() - 40 - i * 24
                HudText:Draw(HudText:T("age", age()), 50, y - 12, 1, 0.85, 0.5, 0.9)
                if usage.limited > 0 then
                    HudText:Draw(HudText:T("limited", math.ceil(usage.limited / 30)), 50, y, 1, 0.3, 0.3, 1)
                else
                    HudText:Draw(HudText:T("usage", usage.value), 50, y, 1, 0.65, 0.3, 1)
                end
            end
        end
    end)
end

return ClaudeChan
