-- Claude family backlog items 02-04 (01 Summary Stapler lives in its own file).
--
-- 02 Rejection Letter (P): after a real enemy-caused hit, remove up to three
--    ordinary hostile bullets within 120 units. Once per room; the hit stays.
-- 03 Dario's Red Stamp (A6): stamp the nearest vulnerable enemy within 220
--    units for 4 seconds: native slow, and no contact damage from that enemy.
--    A boss is only slowed. No target keeps the charge. The stamp is a
--    fictional review mark; no person appears as an enemy.
-- 04 Anniversary Cake (P): each floor finished without an enemy-caused hit
--    and without a suspension adds +0.15 damage, cap +0.6. A spoiled floor
--    resets only this bonus. Saved per player.

local Constants = include("scripts.constants")

local Claude = {}

local STAMP_FRAMES, STAMP_RANGE = 120, 220
local CAKE_STEP, CAKE_CAP = 0.15, 0.6

function Claude:Init(mod, Risk, C)
    local Item = Constants.Item

    -- 02 Rejection Letter
    C.On("playerHit", function(player)
        if not player:HasCollectible(Item.REJECTION_LETTER) then return end
        local d = C.Data(player)
        if d.room.rejection then return end
        d.room.rejection = true
        local removed = 0
        for _, bullet in ipairs(C.Bullets(player.Position, 120, 3)) do
            bullet:Remove(); removed = removed + 1
        end
        if removed > 0 then C.Caption("Rejection Letter", "We regret to inform you") end
    end)

    -- 03 Dario's Red Stamp
    local stamps = {}
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local target = C.NearestEnemy(player.Position, STAMP_RANGE)
        if not target then return C.NoUse() end
        target:AddSlowing(EntityRef(player), STAMP_FRAMES, 0.5, Color(1, 0.4, 0.4, 1, 0.3, 0, 0))
        if not target:IsBoss() then
            stamps[GetPtrHash(target)] = { ref = EntityPtr(target), expires = C.Now() + STAMP_FRAMES }
        end
        C.Caption("Stamped", target:IsBoss() and "Slowed, still dangerous" or "Contact damage suspended")
        return C.Used()
    end, Item.RED_STAMP)
    C.BlockContact(function(_, e)
        local stamp = stamps[GetPtrHash(e)]
        return stamp ~= nil and stamp.expires >= C.Now() and stamp.ref.Ref ~= nil
            and GetPtrHash(stamp.ref.Ref) == GetPtrHash(e)
    end)
    C.On("newRoom", function() stamps = {} end)

    -- 04 Anniversary Cake: the verdict is read from the finished floor's table.
    local function cakeFloor(player)
        local s = C.State(player)
        return s and s.floor
    end
    C.On("playerHit", function(player)
        if player:HasCollectible(Item.ANNIVERSARY_CAKE) then
            local f = cakeFloor(player); if f then f.cakeSpoiled = true end
        end
    end)
    C.On("update", function(frame)
        if frame % 15 ~= 0 then return end
        for _, p in ipairs(C.Players()) do
            if p:HasCollectible(Item.ANNIVERSARY_CAKE) then
                local f = cakeFloor(p)
                if f then
                    f.cakeHeld = true
                    if Risk:IsSuspended() then f.cakeSpoiled = true end
                end
            end
        end
    end)
    C.On("floorChanged", function(player, s, old)
        if not old.cakeHeld then return end
        local bonus = C.Num(s.cake, 0, 0, CAKE_CAP)
        bonus = old.cakeSpoiled and 0 or math.min(CAKE_CAP, bonus + CAKE_STEP)
        s.cake = bonus
        C.Refresh(player)
        C.Caption("Anniversary Cake", bonus > 0 and string.format("Damage +%.2f", bonus) or "The streak is over")
    end)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag ~= CacheFlag.CACHE_DAMAGE or not player:HasCollectible(Item.ANNIVERSARY_CAKE) then return end
        local s = C.State(player)
        local bonus = s and C.Num(s.cake, 0, 0, CAKE_CAP) or 0
        if bonus > 0 then player.Damage = player.Damage + bonus end
    end)
end

return Claude
