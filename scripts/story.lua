-- Short, non-blocking fan-fiction chapters. Progress and pending captions save with the run.
local HudText = include("scripts.hud_text")
local HudLayout = include("scripts.hud_layout")
local Story = {}
local BITS = { story_1 = 1, story_2 = 2, story_3 = 4, story_review = 8,
    story_2_reviewed = 2, story_3_reviewed = 4 }

function Story:Init(mod, Risk)
    local active, timer, ready
    local function seen()
        return type(Risk.state.storySeen) == "number" and Risk.state.storySeen or 0
    end
    local function pending()
        if type(Risk.state.storyPending) ~= "table" then Risk.state.storyPending = {} end
        return Risk.state.storyPending
    end
    local function nextCaption()
        active, timer = nil, 0
        local queue = pending()
        while #queue > 0 do
            local key = table.remove(queue, 1)
            local bit = BITS[key]
            if bit and (seen() & bit) == 0 then
                active, timer = key, 210
                Risk.state.storySeen = seen() | bit
                return
            end
        end
    end
    local function chapter(reviewOnly)
        -- The appeal story is about bans; a DeepSeek-only run never gets banned.
        if Risk.IsActive and not Risk:IsActive() then return end
        local stage = Game():GetLevel():GetStage()
        local key = stage >= 5 and "story_3" or stage >= 3 and "story_2" or "story_1"
        if reviewOnly then
            if not Risk.state.reviewApproved then return end
            key = "story_review"
        elseif Risk.state.reviewApproved and (key == "story_2" or key == "story_3") then
            key = key .. "_reviewed"
        end
        local bit = BITS[key]
        if (seen() & bit) ~= 0 then return end
        local queue = pending()
        for _, queued in ipairs(queue) do
            if BITS[queued] == bit then return end
        end
        queue[#queue + 1] = key
        -- Preserve an active caption when room/floor callbacks occur together.
        -- Queued chapters become seen only when they actually begin.
        if not active then nextCaption() end
    end
    local function start()
        active, timer, ready = nil, 0, true
        nextCaption() -- Resume unseen captions saved behind the previous active one.
        chapter(false)
    end
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, start)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        if ready then chapter(false) end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        if ready then chapter(true) end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if ready and timer and timer > 0 then
            timer = timer - 1
            if timer == 0 then nextCaption() end
        end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready or not active or not Game():GetHUD():IsVisible() then return end
        local y = HudLayout.CaptionY()
        HudText:Draw(HudText:T(active .. "_title"), 100, y, 1, 0.8, 0.5, 0.9)
        HudText:Draw(HudText:T(active .. "_line"), 100, y + 12, 1, 1, 1, 0.9)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        active, timer, ready = nil, 0, false
    end)
    return start
end

return Story
