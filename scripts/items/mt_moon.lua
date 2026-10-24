-- Stuck in Mt. Moon (trinket)
-- Claude Plays Pokemon parody: the stream spent days wandering one cave.
-- Re-entering already cleared rooms six times on a floor finally reveals the
-- floor layout with the native map effect, once per floor. Progress is saved
-- per player; the room present when a run is continued never counts.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Moon = {}

Moon.VISITS = 6

function Moon:Init(mod, Risk)
    local lastRoom

    -- The room descriptor's SafeGridIndex identifies the current room; the
    -- documented GetCurrentRoomIndex refers to the room entered from.
    local function current()
        local desc = Game():GetLevel():GetCurrentRoomDesc()
        return desc and desc.SafeGridIndex or -1
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function() lastRoom = current() end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() lastRoom = nil end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        local index = current()
        -- Covers both callback orders on continue, and duplicate callbacks.
        if lastRoom == nil or index == lastRoom then lastRoom = index; return end
        lastRoom = index
        local room = Game():GetRoom()
        if room:IsFirstVisit() or not room:IsClear() then return end
        for _, player in ipairs(MemeState.Holders(Constants.Trinket.MT_MOON)) do
            local s = MemeState.For(Risk, player)
            if s and not s.moonDone then
                s.moonVisits = s.moonVisits + 1
                if s.moonVisits >= Moon.VISITS then
                    s.moonDone = true
                    Game():GetLevel():ApplyMapEffect()
                    Game():GetHUD():ShowItemText("Finally out of Mt. Moon", "The map was there all along")
                end
            end
        end
    end)
end

return Moon
