-- I Panicked (active, 6 charges)
-- Parody of the coding agent that "panicked" and deleted a production
-- database: every vulnerable non-boss enemy in the room takes lethal native
-- damage and bosses lose 15% of their max HP, but every loose consumable in
-- the room (hearts, coins, keys, bombs, pills, cards, batteries, sacks) is
-- deleted too. Pedestals, trinkets, chests and shop items are never touched.
-- A room with no target keeps the charge. Damage goes through TakeDamage, so
-- on-kill and on-hit effects from other items still apply.

local Constants = include("scripts.constants")

local Panic = {}

Panic.BOSS_SHARE = 0.15

local function deletable(pickup)
    if pickup:IsShopItem() then return false end
    local v = pickup.Variant
    return v == PickupVariant.PICKUP_HEART or v == PickupVariant.PICKUP_COIN
        or v == PickupVariant.PICKUP_KEY or v == PickupVariant.PICKUP_BOMB
        or v == PickupVariant.PICKUP_PILL or v == PickupVariant.PICKUP_TAROTCARD
        or v == PickupVariant.PICKUP_LIL_BATTERY or v == PickupVariant.PICKUP_GRAB_BAG
end

function Panic:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        local batteryRepeat = ((flags or 0) & UseFlag.USE_CARBATTERY) ~= 0
        local targets, pickups = {}, {}
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local npc = entity:ToNPC()
            local pickup = entity:ToPickup()
            if npc and not npc:IsDead() and npc:IsVulnerableEnemy()
                    and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                targets[#targets + 1] = npc
            elseif pickup and not batteryRepeat and deletable(pickup) then
                pickups[#pickups + 1] = pickup
            end
        end
        if #targets == 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local source = EntityRef(player)
        for _, npc in ipairs(targets) do
            if npc:IsBoss() then
                npc:TakeDamage(npc.MaxHitPoints * Panic.BOSS_SHARE, 0, source, 0)
            else
                npc:TakeDamage(npc.HitPoints + npc.MaxHitPoints, 0, source, 0)
            end
        end
        for _, pickup in ipairs(pickups) do pickup:Remove() end
        -- Car Battery's second call hits again but deletes nothing new.
        if not batteryRepeat then
            Game():GetHUD():ShowItemText("I panicked", "This was a catastrophic failure on my part")
        end
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.I_PANICKED)
end

return Panic
