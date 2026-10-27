-- Disgrace Loop (trinket)
-- Parody of the widely shared "I am a disgrace" self-criticism loop: the
-- first real hit a holder takes in a room freezes every vulnerable enemy for
-- 1.5 seconds while they watch the meltdown. Fake and penalty-free damage
-- (Blood Donation, IV Bag) never triggers it; other self-inflicted hits such
-- as your own bombs do. The hit is not cancelled. Once per room per player;
-- nothing is saved.

local Constants = include("scripts.constants")

local Disgrace = {}

local FREEZE_FRAMES = 45

function Disgrace:Init(mod)
    local used = {}

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() used = {} end)

    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, _, flags)
        local player = entity:ToPlayer()
        if not player or not player:HasTrinket(Constants.Trinket.DISGRACE_LOOP) then return end
        if (flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES)) ~= 0 then return end
        local key = GetPtrHash(player)
        if used[key] then return end
        used[key] = true
        local ref = EntityRef(player)
        for _, e in ipairs(Isaac.GetRoomEntities()) do
            local npc = e:ToNPC()
            if npc and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                npc:AddFreeze(ref, FREEZE_FRAMES)
            end
        end
        Game():GetHUD():ShowItemText("I am a disgrace", "Everyone stops to watch")
    end, EntityType.ENTITY_PLAYER)
end

return Disgrace
