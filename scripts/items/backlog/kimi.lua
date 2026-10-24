-- Kimi family backlog items 37-40.
--
-- 37 Slide Deadline (A4): mark up to three nearest enemies within 250 units
--    for eight seconds. Killing all of them in time gives +15% owner damage
--    for the rest of the room. One batch at a time; no target keeps charge.
-- 38 Citation Thread (P): an attack hit marks its target as the first
--    reference; hitting a different enemy then grants +10% damage against the
--    first one for three seconds. At most two references.
-- 39 Overtime Slides (P): every third unique clear primes a two-second slowing
--    outline on up to three enemies when the next hostile room starts.
-- 40 Stand-Up Meeting (A6): recall up to three temporary helpers made by
--    backlog items (Unchanged Preview decoys) for one 2x damage burst at each
--    location (60 units). Vanilla familiars are never touched. No helper
--    keeps the charge.

local Constants = include("scripts.constants")

local Kimi = {}

local DEADLINE_FRAMES, DEADLINE_RANGE = 240, 250
local CITATION_FRAMES = 90
local BURST_RADIUS = 60

function Kimi:Init(mod, Risk, C)
    local Item = Constants.Item
    C.WatchClears(Item.OVERTIME_SLIDES)

    -- 37 Slide Deadline
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local r = C.Data(player).room
        if r.deadline and r.deadline.expires >= C.Now() then return C.NoUse() end
        local targets = C.Nearby(player.Position, DEADLINE_RANGE, 3)
        if #targets == 0 then return C.NoUse() end
        local batch = { expires = C.Now() + DEADLINE_FRAMES, left = {}, count = #targets }
        for _, npc in ipairs(targets) do
            batch.left[GetPtrHash(npc)] = true
            npc:SetColor(Color(1, 1, 1, 1, 0.1, 0.1, 0.35), DEADLINE_FRAMES, 1, false, false)
        end
        r.deadline = batch
        C.Caption("Slide Deadline", string.format("%d slides due", #targets))
        return C.Used()
    end, Item.SLIDE_DEADLINE)
    C.On("kill", function(npc)
        for _, p in ipairs(C.Players()) do
            local r = C.Data(p).room
            local b = r.deadline
            if b and b.expires >= C.Now() and b.left[GetPtrHash(npc)] then
                b.left[GetPtrHash(npc)] = nil
                if next(b.left) == nil then
                    r.deadline, r.deadlineMet = nil, true
                    C.Refresh(p)
                    C.Label(p, "deadline", "Deadline met +15%")
                end
            end
        end
    end)
    C.Stat("damage", function(p) return C.Data(p).room.deadlineMet and 1.15 or 1 end)

    -- 38 Citation Thread
    C.On("hit", function(npc, player, _, attackId)
        if not attackId or not player:HasCollectible(Item.CITATION_THREAD) then return end
        local r = C.Data(player).room
        local hash = GetPtrHash(npc)
        if not r.citeFirst then
            r.citeFirst = hash
        elseif hash ~= r.citeFirst and not r.citeSecond then
            r.citeSecond = hash
            r.citeUntil = C.Now() + CITATION_FRAMES
        elseif r.citeUntil and r.citeUntil < C.Now() then
            r.citeFirst, r.citeSecond, r.citeUntil = hash, nil, nil
        end
    end)
    C.TargetModifier(function(npc, player)
        local r = C.Data(player).room
        if r.citeUntil and r.citeUntil >= C.Now() and r.citeFirst == GetPtrHash(npc)
            and player:HasCollectible(Item.CITATION_THREAD) then return 1.1 end
        return 1
    end)

    -- 39 Overtime Slides
    C.On("uniqueClear", function()
        for _, p in ipairs(C.Players()) do
            if p:HasCollectible(Item.OVERTIME_SLIDES) then
                local s = C.State(p)
                if s and not s.overtimeReady then
                    s.overtime = C.Num(s.overtime, 0, 0, 3) + 1
                    if s.overtime >= 3 then s.overtime, s.overtimeReady = 0, true end
                end
            end
        end
    end)
    C.On("newRoom", function(room)
        if room:IsClear() then return end
        for _, p in ipairs(C.Players()) do
            local s = C.Peek(p)
            if s and s.overtimeReady and p:HasCollectible(Item.OVERTIME_SLIDES) then
                s.overtimeReady = nil
                C.After(1, function()
                    for _, npc in ipairs(C.Nearby(p.Position, 1000, 3)) do
                        npc:AddSlowing(EntityRef(p), 60, 0.5, Color(0.7, 0.7, 1, 1, 0.1, 0.1, 0.3))
                    end
                end, true)
            end
        end
    end)

    -- 40 Stand-Up Meeting
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local list = C.Helpers(player)
        if #list == 0 then return C.NoUse() end
        for i = 1, math.min(3, #list) do
            local helper = list[i].entity
            for _, npc in ipairs(C.Nearby(helper.Position, BURST_RADIUS)) do C.Pulse(npc, player, 2) end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, helper.Position, Vector.Zero, player)
            helper:Remove()
        end
        C.Caption("Stand-Up Meeting", "Status updates delivered")
        return C.Used()
    end, Item.STANDUP_MEETING)
end

return Kimi
