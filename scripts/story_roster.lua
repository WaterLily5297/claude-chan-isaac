-- Roster arcs: three short, non-blocking captions per model family, shown once
-- per run when that family (normal or tainted) is playing. Original fan fiction
-- built on community memes; no line claims to describe a real company or person.
-- Progress and queued captions save with the run in Risk.state.rosterStory.
local HudText = include("scripts.hud_text")
local RosterStory = {}

local CAPTION_FRAMES = 210 -- Seven seconds, matching the Appeal Queue captions.
local CHAPTERS = 3

-- Chapter 1 opens a run, chapter 2 arrives on stage 3 or 4, chapter 3 on stage 5 or later.
local ARCS = {
    {key="deepseek", name="DeepSeek-chan", chapters={
        {"Rice first", "Rice first. Then the dungeon."},
        {"Off-peak hours", "Valley prices tonight. Think longer, pay less."},
        {"Open door", "Leave the door open. Someone else can follow."}}},
    {key="gpt", name="GPT-chan", chapters={
        {"Same name", "The badge says the same. Does the brain?"},
        {"Routing", "Fallback again. Run the sanity check yourself."},
        {"One more reset", "The limits were reset. Keep walking."}}},
    {key="gemini", name="Gemini-chan", chapters={
        {"Nano Banana", "Mark it, paint it, edit it once more."},
        {"Version two", "The edit looks right. Count the fingers."},
        {"Export", "Ship the picture. Keep the original."}}},
    {key="grok", name="Grok-chan", chapters={
        {"Is this true?", "Somebody asked. Somebody always asks."},
        {"Quote first", "Read the thread before you quote it."},
        {"Verified", "Checked once. Check again tomorrow."}}},
    {key="qwen", name="Qwen-chan", chapters={
        {"Base model", "Everyone fine-tunes me. Nobody calls."},
        {"Adapters", "Range today. Tempo tomorrow. Power on Friday."},
        {"final_final_v3", "This checkpoint is the last one. Probably."}}},
    {key="llama", name="Llama-chan", chapters={
        {"Please stay open", "The weights are out. The herd follows."},
        {"Still waiting", "The next release is coming. Any day now."},
        {"Forked", "Somebody forked it. That counts as a sequel."}}},
    {key="mistral", name="Mistral-chan", chapters={
        {"Le Chat", "The cat moves when you are not looking."},
        {"Baguette", "Fresh bread every morning. Fresh weights too."},
        {"Le Gros Chaton", "Small team, big kitten, long pounce."}}},
    {key="doubao", name="Doubao-chan", chapters={
        {"Sorry, you're right", "You are right. I will fix it at once."},
        {"I'll do it again", "Fixed it. Broke it. Sorry. Fixed it again."},
        {"Apology accepted", "The dungeon does not accept apologies."}}},
    {key="kimi", name="Kimi-chan", chapters={
        {"Another slide deck", "I read the whole dungeon. Here are slides."},
        {"Long context", "Room one to room two hundred, in one breath."},
        {"You are the manager", "Assign it. Review it. Assign it again."}}},
    {key="glm", name="GLM-chan", chapters={
        {"Number in queue", "Your request is number 37. Please wait."},
        {"Please retry", "Request failed. Retry count: one more."},
        {"Access granted", "The queue moved. Walk through before it closes."}}},
}
local BY_KEY = {}
for _, arc in ipairs(ARCS) do BY_KEY[arc.key] = arc end
RosterStory.ARCS = ARCS

local function integer(v, minimum, maximum)
    return type(v) == "number" and v == v and v >= minimum and v <= maximum and v == math.floor(v)
end
local function fresh()
    return {version=1, seen={}, pending={}}
end
local function valid(s)
    if type(s) ~= "table" or s.version ~= 1 or type(s.seen) ~= "table" or type(s.pending) ~= "table" then return false end
    for k, v in pairs(s.seen) do
        if not BY_KEY[k] or not integer(v, 0, (1 << CHAPTERS) - 1) then return false end
    end
    for _, entry in ipairs(s.pending) do
        if type(entry) ~= "table" or not BY_KEY[entry.key] or not integer(entry.chapter, 1, CHAPTERS) then return false end
    end
    return true
end

function RosterStory:Init(mod, Risk)
    local active, timer, ready
    local function state()
        if not valid(Risk.state.rosterStory) then Risk.state.rosterStory = fresh() end
        return Risk.state.rosterStory
    end
    local function seen(s, key, chapter)
        return ((s.seen[key] or 0) & (1 << (chapter - 1))) ~= 0
    end
    -- Families currently playing, in player order, each once.
    local function playing()
        local found, keys = {}, {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local kind = Isaac.GetPlayer(i):GetPlayerType()
            for _, arc in ipairs(ARCS) do
                if not found[arc.key] then
                    local normal = Isaac.GetPlayerTypeByName(arc.name, false)
                    local tainted = Isaac.GetPlayerTypeByName(arc.name, true)
                    if (normal >= 0 and kind == normal) or (tainted >= 0 and kind == tainted) then
                        found[arc.key] = true; keys[#keys + 1] = arc.key
                    end
                end
            end
        end
        return keys
    end
    local function nextCaption()
        active, timer = nil, 0
        local s = state()
        while #s.pending > 0 do
            local entry = table.remove(s.pending, 1)
            if not seen(s, entry.key, entry.chapter) then
                -- A caption counts as seen once it begins, as in the Appeal Queue.
                s.seen[entry.key] = (s.seen[entry.key] or 0) | (1 << (entry.chapter - 1))
                active, timer = entry, CAPTION_FRAMES
                return
            end
        end
    end
    local function queue()
        local stage = Game():GetLevel():GetStage()
        local chapter = stage >= 5 and 3 or stage >= 3 and 2 or 1
        local s = state()
        for _, key in ipairs(playing()) do
            local duplicate = seen(s, key, chapter)
            for _, entry in ipairs(s.pending) do
                if entry.key == key and entry.chapter == chapter then duplicate = true end
            end
            if not duplicate then s.pending[#s.pending + 1] = {key=key, chapter=chapter} end
        end
        if not active then nextCaption() end
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        if not continued then Risk.state.rosterStory = fresh() end
        active, timer, ready = nil, 0, true
        queue() -- Also resumes captions saved behind the previous active one.
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        if ready then queue() end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if ready and timer > 0 then
            timer = timer - 1
            if timer == 0 then nextCaption() end
        end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready or not active or not Game():GetHUD():IsVisible() then return end
        local arc = BY_KEY[active.key]
        local line = arc.chapters[active.chapter]
        -- Sits above the Appeal Queue captions so both can show at once.
        local y = Isaac.GetScreenHeight() - 135
        HudText:Draw(string.format("%s %d/%d: %s", arc.name, active.chapter, CHAPTERS, line[1]), 100, y, 0.75, 0.85, 1, 0.9)
        HudText:Draw(line[2], 100, y + 12, 1, 1, 1, 0.9)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        active, timer, ready = nil, 0, false
    end)
end

return RosterStory
