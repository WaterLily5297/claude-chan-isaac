-- Qwen family backlog items 21-24.
--
-- 21 Base Model (P): the first successful charged active use in each room
--    primes one 1.3x attack. Zero-charge, timed and Car Battery uses never
--    count, and no charge is refunded.
-- 22 Another Adapter (A4): apply one room-local bonus and advance the saved
--    choice: +60 range, then +0.15 speed, then +15% damage. Each use replaces
--    the current bonus; it ends when the room does.
-- 23 Final Final Weights (P): two unique flawless clears bank +20% damage for
--    the next hostile room. A hit resets unbanked progress; one bank at most.
-- 24 Tiny Variant (P): +0.15 speed and x0.9 damage, through the cache only.
--    Sprite scale and native size items are untouched.

local Constants = include("scripts.constants")

local Qwen = {}

local ADAPTERS = { "range", "speed", "damage" }
local LABELS = { range = "Adapter: +60 range", speed = "Adapter: +0.15 speed", damage = "Adapter: +15% damage" }

function Qwen:Init(mod, Risk, C)
    local Item = Constants.Item
    C.WatchClears(Item.FINAL_WEIGHTS)

    -- 21 Base Model
    C.On("activeUsed", function(player)
        if not player:HasCollectible(Item.BASE_MODEL) then return end
        local d = C.Data(player)
        if d.room.baseModel then return end
        d.room.baseModel = true
        C.Prime(player, "baseModel", 1.3)
    end)

    -- 22 Another Adapter
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local s = C.State(player)
        if not s then return C.NoUse() end
        local index = math.floor(C.Num(s.adapter, 1, 1, #ADAPTERS))
        local choice = ADAPTERS[index]
        s.adapter = index % #ADAPTERS + 1
        C.Data(player).room.adapter = choice
        C.Refresh(player)
        C.Caption("Another Adapter", LABELS[choice])
        return C.Used()
    end, Item.ANOTHER_ADAPTER)
    C.Stat("range", function(p) return C.Data(p).room.adapter == "range" and 60 or 0 end)
    C.Stat("speed", function(p)
        local add = C.Data(p).room.adapter == "speed" and 0.15 or 0
        if p:HasCollectible(Item.TINY_VARIANT) then add = add + 0.15 * p:GetCollectibleNum(Item.TINY_VARIANT) end
        return add
    end)
    C.Stat("damage", function(p)
        local m = C.Data(p).room.adapter == "damage" and 1.15 or 1
        if C.Data(p).room.weights then m = m * 1.2 end
        if p:HasCollectible(Item.TINY_VARIANT) then m = m * (0.9 ^ p:GetCollectibleNum(Item.TINY_VARIANT)) end
        return m
    end)

    -- 23 Final Final Weights
    C.On("uniqueClear", function(flawless)
        for _, p in ipairs(C.Players()) do
            if p:HasCollectible(Item.FINAL_WEIGHTS) then
                local s = C.State(p)
                if s and not s.weightsBanked then
                    if flawless(p) then
                        s.weights = C.Num(s.weights, 0, 0, 2) + 1
                        if s.weights >= 2 then s.weights, s.weightsBanked = 0, true end
                    else
                        s.weights = 0
                    end
                end
            end
        end
    end)
    C.On("playerHit", function(player)
        if player:HasCollectible(Item.FINAL_WEIGHTS) then
            local s = C.State(player); if s and not s.weightsBanked then s.weights = 0 end
        end
    end)
    C.On("newRoom", function(room)
        if room:IsClear() then return end
        for _, p in ipairs(C.Players()) do
            local s = C.Peek(p)
            if s and s.weightsBanked and p:HasCollectible(Item.FINAL_WEIGHTS) then
                s.weightsBanked = nil
                C.Data(p).room.weights = true
                C.Label(p, "weights", "Final weights +20%")
                C.Refresh(p)
            end
        end
    end)
end

return Qwen
