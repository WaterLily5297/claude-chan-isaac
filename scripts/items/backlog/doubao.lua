-- Doubao family backlog items 33-36.
--
-- 33 Instant Apology (A4): slow enemies within 150 units for two seconds and
--    erase up to four ordinary hostile bullets there. No healing; a hit
--    already taken stays. Nothing to slow or erase keeps the charge.
-- 34 Next Time Again (P): the first real enemy-caused hit in a room primes
--    +50% on one attack within four seconds. One per room.
-- 35 Confident Answer (A4): six seconds at +25% damage, then four seconds at
--    -10%. Cycles never overlap (use during one keeps the charge); the phase
--    is shown. Leaving the room ends it without refund.
-- 36 Smiling Correction (P): after real enemy damage, the next unique
--    flawless clear gives two blue flies. One pending correction at most.

local Constants = include("scripts.constants")

local Doubao = {}

local APOLOGY_RADIUS, APOLOGY_FRAMES = 150, 60
local UP, DOWN = 180, 120

function Doubao:Init(mod, Risk, C)
    local Item = Constants.Item
    C.WatchClears(Item.SMILING_CORRECTION)

    -- 33 Instant Apology
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local enemies = C.Nearby(player.Position, APOLOGY_RADIUS)
        local bullets = C.Bullets(player.Position, APOLOGY_RADIUS, 4)
        if #enemies == 0 and #bullets == 0 then return C.NoUse() end
        for _, npc in ipairs(enemies) do
            npc:AddSlowing(EntityRef(player), APOLOGY_FRAMES, 0.5, Color(0.8, 0.8, 1, 1, 0.1, 0.1, 0.3))
        end
        for _, b in ipairs(bullets) do b:Remove() end
        C.Caption("Sorry for the confusion!", "Let me correct that")
        return C.Used()
    end, Item.INSTANT_APOLOGY)

    C.On("playerHit", function(player)
        -- 34 Next Time Again
        if player:HasCollectible(Item.NEXT_TIME_AGAIN) then
            local d = C.Data(player)
            if not d.room.nextTime then
                d.room.nextTime = true
                C.Prime(player, "nextTime", 1.5, 120)
            end
        end
        -- 36 Smiling Correction
        if player:HasCollectible(Item.SMILING_CORRECTION) then
            local s = C.State(player); if s then s.correction = true end
        end
    end)
    C.On("uniqueClear", function(flawless)
        for _, p in ipairs(C.Players()) do
            local s = C.Peek(p)
            if s and s.correction == true and flawless(p) and p:HasCollectible(Item.SMILING_CORRECTION) then
                s.correction = nil
                p:AddBlueFlies(2, p.Position, nil)
                C.Caption("Smiling Correction", "Fixed it this time!")
            end
        end
    end)

    -- 35 Confident Answer
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local d = C.Data(player)
        if d.room.confident and C.Now() - d.room.confident < UP + DOWN then return C.NoUse() end
        d.room.confident = C.Now()
        C.Refresh(player)
        C.Caption("Confident Answer", "Absolutely certain")
        return C.Used()
    end, Item.CONFIDENT_ANSWER)
    C.Stat("damage", function(p)
        local start = C.Data(p).room.confident
        if not start then return 1 end
        local age = C.Now() - start
        if age < UP then return 1.25 elseif age < UP + DOWN then return 0.9 end
        return 1
    end)
    C.On("update", function(frame)
        for _, p in ipairs(C.Players()) do
            local r = C.Data(p).room
            if r.confident then
                local age = frame - r.confident
                if age == UP or age == UP + DOWN then C.Refresh(p) end
                if age < UP then C.Label(p, "confident", "Confident +25%")
                elseif age < UP + DOWN then C.Label(p, "confident", "Correction -10%")
                else C.Label(p, "confident", nil) end
            end
            if C.Primed(p, "nextTime") then C.Label(p, "nextTime", "Next time +50%") else C.Label(p, "nextTime", nil) end
        end
    end)
end

return Doubao
