-- DeepSeek-chan (playable, normal + tainted)
-- Character design: original whale girl 溟月 by 上善无形, maid version by
-- ZipZipPipe (CC BY-NC-SA 4.0); sprites in docs/ART_GENERATION.md.
--
-- She has nothing to do with proxies or IPs: she connects directly, so the
-- risk system sleeps in a DeepSeek-only run (see Risk:IsActive). Her own
-- memes drive her instead:
--
-- Normal - "Deep Think" (深度思考):
--   Not shooting fills a thinking timer (up to 5 s). The next tear deals
--   x(1 + 0.2 per second thought), up to x2, and the HUD reads
--   "Thought for N s" (已深度思考（用时 N 秒）).
--   "Server busy" (服务器繁忙): the more enemies in the room, the more often
--   a tear simply doesn't go out (3% per enemy, at most 25%).
--   Pocket item: Lunch Break (去吃饭了). Damage x0.9, blue tears.
--   Slacking off (摸鱼, after the viral 10.19 Bilibili video "大肥鱼成精了！在摸鱼！"):
--   standing still for 5 s in a cleared room recharges Lunch Break by one.
--
-- Tainted - "Open Source" (开源):
--   Every tear is forked: two extra copies at ±12° with 50% damage, because
--   anyone can fork the open weights. Damage x0.8. Being that popular means
--   the servers are busier: 5% per enemy, at most 40%. No Deep Think.

local Constants = include("scripts.constants")
local HudText = include("scripts.hud_text")
local TearFork = include("scripts.tear_fork")

local DeepSeek = {}

local THINK_MAX_FRAMES = 150      -- 5 s
local THINK_MIN_FRAMES = 30       -- under 1 s doesn't count as thinking
local THINK_PER_SECOND = 0.2
local NORMAL_DAMAGE = 0.9
local TAINTED_DAMAGE = 0.8
local FORK_SPREAD = 12
local FORK_DAMAGE = 0.5
local BUSY = { normal = { per = 0.03, max = 0.25 }, tainted = { per = 0.05, max = 0.4 } }
local MESSAGE_FRAMES = 60
local SLACK_FRAMES = 150          -- 5 s standing still in a cleared room
local SLACK_SPEED = 0.1
local LUNCH_MAX_CHARGE = 6

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
        data.ccDeepSeek = { lastTear = Game():GetFrameCount(), message = nil, messageUntil = 0 }
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
        if not k then return end
        local s = state(player)

        -- Server busy: the tear never goes out. Thinking time is kept.
        local busy = BUSY[k]
        if rng:RandomFloat() < math.min(busy.max, Isaac.CountEnemies() * busy.per) then
            tear:Remove()
            say(s, "busy")
            return
        end

        if k == "normal" then
            local now = Game():GetFrameCount()
            local thought = math.min(THINK_MAX_FRAMES, now - s.lastTear)
            s.lastTear = now
            if thought >= THINK_MIN_FRAMES then
                local seconds = thought / 30
                tear.CollisionDamage = tear.CollisionDamage * (1 + THINK_PER_SECOND * seconds)
                tear.Scale = tear.Scale * (1 + 0.1 * seconds)
                say(s, "thought", math.floor(seconds))
            end
        else
            for _, angle in ipairs({ -FORK_SPREAD, FORK_SPREAD }) do
                local fork = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, 0, tear.Position,
                    tear.Velocity:Rotated(angle), player):ToTear()
                if fork then
                    TearFork.Copy(tear, fork, FORK_DAMAGE)
                end
            end
        end
    end)

    -- 摸鱼: idle in a cleared room refills the pocket Lunch Break, one charge at a time.
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
        if kind(player) ~= "normal" then return end
        local s = state(player)
        local slot = ActiveSlot.SLOT_POCKET
        if not Game():GetRoom():IsClear() or player.Velocity:Length() > SLACK_SPEED
            or player:GetActiveItem(slot) ~= Constants.Item.LUNCH_BREAK
            or player:GetActiveCharge(slot) >= LUNCH_MAX_CHARGE then
            s.slack = 0
            return
        end
        s.slack = (s.slack or 0) + 1
        if s.slack >= SLACK_FRAMES then
            s.slack = 0
            player:SetActiveCharge(player:GetActiveCharge(slot) + 1, slot)
            say(s, "slacking")
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not Game():GetHUD():IsVisible() then return end
        local now = Game():GetFrameCount()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            local s = kind(player) and player:GetData().ccDeepSeek
            if s and s.message and now < s.messageUntil then
                local y = Isaac.GetScreenHeight() - 40 - i * 12
                local text = s.message == "thought" and HudText:T("thought", s.value) or HudText:T(s.message)
                HudText:Draw(text, 50, y, 0.45, 0.75, 1, 1)
            end
        end
    end)
end

return DeepSeek
