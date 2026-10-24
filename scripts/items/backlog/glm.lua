-- GLM family backlog items 41-44.
--
-- 41 Queue Ticket (P): every fourth unique combat clear adds one charge to an
--    eligible primary active. Re-entry never counts; timed and zero-charge
--    actives never benefit.
-- 42 Sold Out (A4): one ordinary-bullet guard for four seconds, with +0.15
--    speed while it lasts. Using it again while a guard is up keeps the charge,
--    so it never stacks or extends.
-- 43 Please Retry (A6): three native 0.6x tears at half-second intervals along
--    the aim at use. Pending retries are cancelled on room exit, death or a
--    character change; retries are never attacks themselves.
-- 44 Access Pass (P): the first successful charged active use on each floor
--    grants +15% damage for the current combat room, or for the next hostile
--    room when used in a cleared one. One pending reward; Car Battery uses
--    never count.

local Constants = include("scripts.constants")

local Glm = {}

local GUARD_FRAMES, RETRY_GAP = 120, 15

function Glm:Init(mod, Risk, C)
    local Item = Constants.Item
    C.WatchClears(Item.QUEUE_TICKET)

    -- 41 Queue Ticket
    C.On("uniqueClear", function()
        for _, p in ipairs(C.Players()) do
            if p:HasCollectible(Item.QUEUE_TICKET) then
                local s = C.State(p)
                if s then
                    s.queue = C.Num(s.queue, 0, 0, 4) + 1
                    if s.queue >= 4 then
                        s.queue = 0
                        if C.AddCharge(p, 1) then C.Caption("Queue Ticket", "Your turn: +1 charge") end
                    end
                end
            end
        end
    end)

    -- 42 Sold Out
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) or C.Guards(player, "soldOut") > 0 then return C.NoUse() end
        C.AddGuard(player, "soldOut", GUARD_FRAMES, 1)
        C.Data(player).soldOut = C.Now() + GUARD_FRAMES
        C.Refresh(player)
        C.Caption("Sold Out", "Guard for four seconds")
        return C.Used()
    end, Item.SOLD_OUT)
    C.Stat("speed", function(p)
        local untilFrame = C.Data(p).soldOut
        return (untilFrame and untilFrame >= C.Now() and C.Guards(p, "soldOut") > 0) and 0.15 or 0
    end)
    C.On("guarded", function(player, key)
        if key == "soldOut" then C.Data(player).soldOut = nil; C.Refresh(player) end
    end)

    -- 43 Please Retry
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local aim, kind = C.Aim(player), player:GetPlayerType()
        for i = 0, 2 do
            C.After(i * RETRY_GAP + 1, function()
                if player:Exists() and not player:IsDead() and player:GetPlayerType() == kind then
                    C.FireDerived(player, aim * (10 * player.ShotSpeed), 0.6)
                end
            end, true)
        end
        C.Caption("Please Retry", "Request queued (3)")
        return C.Used()
    end, Item.PLEASE_RETRY)

    -- 44 Access Pass
    C.On("activeUsed", function(player, _, roomClear)
        if not player:HasCollectible(Item.ACCESS_PASS) then return end
        local s = C.State(player)
        if not s or s.floor.access then return end
        s.floor.access = true
        if roomClear then s.accessPending = true
        else C.Data(player).room.access = true; C.Refresh(player) end
        C.Caption("Access Pass", "Priority access +15%")
    end)
    C.On("newRoom", function(room)
        if room:IsClear() then return end
        for _, p in ipairs(C.Players()) do
            local s = C.Peek(p)
            if s and s.accessPending and p:HasCollectible(Item.ACCESS_PASS) then
                s.accessPending = nil
                C.Data(p).room.access = true
                C.Refresh(p)
            end
        end
    end)
    C.Stat("damage", function(p) return C.Data(p).room.access and 1.15 or 1 end)

    C.On("update", function(frame)
        for _, p in ipairs(C.Players()) do
            local d = C.Data(p)
            if d.soldOut and d.soldOut < frame then d.soldOut = nil; C.Refresh(p) end
        end
    end)
end

return Glm
