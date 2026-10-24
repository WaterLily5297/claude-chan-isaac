-- GPT family backlog items 09-12.
--
-- 09 Sanity Test (A4): mark the nearest vulnerable enemy within 220 units for
--    six seconds; three distinct attacks hitting it trigger one 3x pulse.
--    Timeout or early death loses the attempt. No target keeps the charge.
-- 10 Routing Receipt (P): three unique combat clears bank +20% damage for the
--    next combat room. Re-entry never advances it; saved per player.
-- 11 Tibo Reset (A12): once per floor, +20% damage for the next two new combat
--    rooms. A second use on the same floor keeps the charge. It resets no
--    quota, active item or world state. (Tainted GPT Credits do not exist yet.)
-- 12 Same Model Badge (P): in each new hostile room, two seconds at +25%
--    damage, then four seconds at -10%, then baseline. The phase is shown.

local Constants = include("scripts.constants")

local Gpt = {}

local TEST_FRAMES, TEST_RANGE, TEST_HITS = 180, 220, 3
local BADGE_UP, BADGE_DOWN = 60, 120

function Gpt:Init(mod, Risk, C)
    local Item = Constants.Item
    C.WatchClears(Item.ROUTING_RECEIPT)

    -- 09 Sanity Test
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local target = C.NearestEnemy(player.Position, TEST_RANGE)
        if not target then return C.NoUse() end
        C.Data(player).room.sanity = { hash = GetPtrHash(target), ref = EntityPtr(target),
            expires = C.Now() + TEST_FRAMES, hits = {}, count = 0 }
        target:SetColor(Color(1, 1, 1, 1, 0.2, 0.2, 0.4), TEST_FRAMES, 1, false, false)
        C.Caption("Sanity Test", "Three different hits")
        return C.Used()
    end, Item.SANITY_TEST)
    C.On("hit", function(npc, player, _, attackId)
        local t = attackId and C.Data(player).room.sanity
        if not t or t.hash ~= GetPtrHash(npc) or t.hits[attackId] then return end
        if t.expires < C.Now() then C.Data(player).room.sanity = nil; return end
        t.hits[attackId] = true
        t.count = t.count + 1
        if t.count >= TEST_HITS then
            C.Data(player).room.sanity = nil
            C.After(1, function() C.Pulse(npc, player, 3) end, true)
            C.Caption("Sanity Test", "Passed")
        end
    end)

    -- 10 Routing Receipt
    C.On("uniqueClear", function()
        for _, p in ipairs(C.Players()) do
            if p:HasCollectible(Item.ROUTING_RECEIPT) then
                local s = C.State(p)
                if s and not s.routingBanked then
                    s.routing = C.Num(s.routing, 0, 0, 3) + 1
                    if s.routing >= 3 then s.routing, s.routingBanked = 0, true end
                end
            end
        end
    end)

    -- 11 Tibo Reset
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local s = C.State(player)
        if not s or s.floor.tibo then return C.NoUse() end
        s.floor.tibo = true
        s.tiboRooms = 2
        C.Caption("Tibo: Reset", "+20% damage for the next two combat rooms")
        return C.Used()
    end, Item.TIBO_RESET)

    -- Pending room bonuses start when a new hostile room is entered.
    C.On("newRoom", function(room)
        if room:IsClear() then return end
        for _, p in ipairs(C.Players()) do
            local s, d = C.Peek(p), C.Data(p)
            if s then
                if s.routingBanked and p:HasCollectible(Item.ROUTING_RECEIPT) then
                    s.routingBanked = nil; d.room.routing = true
                end
                if C.Num(s.tiboRooms, 0, 0, 2) > 0 and room:IsFirstVisit() then
                    s.tiboRooms = s.tiboRooms - 1; d.room.tibo = true
                end
            end
            if p:HasCollectible(Item.SAME_MODEL_BADGE) then d.room.badge = C.Now() end
            C.Refresh(p)
        end
    end)

    C.Stat("damage", function(p)
        local r = C.Data(p).room
        local m = 1
        if r.routing then m = m * 1.2 end
        if r.tibo then m = m * 1.2 end
        if r.badge and p:HasCollectible(Item.SAME_MODEL_BADGE) then
            local age = C.Now() - r.badge
            if age < BADGE_UP then m = m * 1.25 elseif age < BADGE_UP + BADGE_DOWN then m = m * 0.9 end
        end
        return m
    end)

    -- 12 Same Model Badge: refresh exactly at phase boundaries.
    C.On("update", function(frame)
        for _, p in ipairs(C.Players()) do
            local r = C.Data(p).room
            if r.badge then
                local age = frame - r.badge
                if age == BADGE_UP or age == BADGE_UP + BADGE_DOWN then C.Refresh(p) end
                if age < BADGE_UP then C.Label(p, "badge", "Model: Verified +25%")
                elseif age < BADGE_UP + BADGE_DOWN then C.Label(p, "badge", "Model: Fallback -10%")
                else C.Label(p, "badge", nil); r.badge = nil end
            end
            if r.routing then C.Label(p, "routing", "Routing +20%") end
            if r.tibo then C.Label(p, "tibo", "Tibo +20%") end
        end
    end)
end

return Gpt
