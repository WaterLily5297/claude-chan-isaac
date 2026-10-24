-- One Small Rock a Day (trinket)
-- Search-summary parody ("eat at least one small rock per day"): once per
-- floor, the first rock broken in the room heals each holder who can take
-- red hearts by half a heart. Holders at full health keep their daily rock.
-- Only rocks intact on room entry are watched, polled every six updates.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Rock = {}

local POLL_FRAMES, BROKEN = 6, 2

local function hungry(Risk)
    local list = {}
    for _, player in ipairs(MemeState.Holders(Constants.Trinket.SMALL_ROCK)) do
        local s = MemeState.For(Risk, player)
        if s and not s.rockUsed then list[#list + 1] = { player = player, state = s } end
    end
    return list
end

function Rock:Init(mod, Risk)
    local watched

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() watched = nil end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() watched = nil end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if Game():GetFrameCount() % POLL_FRAMES ~= 0 then return end
        local eaters = hungry(Risk)
        if #eaters == 0 then return end
        local room = Game():GetRoom()
        if not watched then
            -- Built lazily, so picking the trinket up mid-room still works.
            watched = {}
            for index = 0, room:GetGridSize() - 1 do
                local grid = room:GetGridEntity(index)
                local rock = grid and grid:ToRock()
                if rock and rock.State ~= BROKEN then watched[#watched + 1] = index end
            end
            return
        end
        local broke = false
        for i = #watched, 1, -1 do
            local grid = room:GetGridEntity(watched[i])
            local rock = grid and grid:ToRock()
            if not rock or rock.State == BROKEN then
                table.remove(watched, i)
                broke = true
            end
        end
        if not broke then return end
        for _, eater in ipairs(eaters) do
            if eater.player:CanPickRedHearts() then
                eater.player:AddHearts(1)
                eater.state.rockUsed = true
                Game():GetHUD():ShowItemText("One small rock a day", "Geologists recommend it")
            end
        end
    end)
end

return Rock
