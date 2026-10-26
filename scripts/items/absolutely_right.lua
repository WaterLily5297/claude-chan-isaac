-- You're Absolutely Right! (passive)
-- Sycophancy, weaponised: any enemy that hurts you immediately agrees with you
-- and fights on your side for 5 seconds. You still take the hit.

local Constants = include("scripts.constants")

local AbsolutelyRight = {}

local CHARM_FRAMES = 150

function AbsolutelyRight:Init(mod)
    -- React after ordinary shields, including the later-registered backlog.
    -- This is still pre-damage: a veto after LATE cannot be observed here.
    mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, function(_, entity, _, _, source)
        local player = entity:ToPlayer()
        if not player or not player:HasCollectible(Constants.Item.ABSOLUTELY_RIGHT) then
            return
        end

        -- The source may be a projectile; charm whoever fired it.
        local attacker = source and source.Entity
        if attacker and attacker.Type == EntityType.ENTITY_PROJECTILE then
            attacker = attacker.SpawnerEntity
        end

        local npc = attacker and attacker:ToNPC()
        if npc and not npc:IsBoss() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            npc:AddCharmed(EntityRef(player), CHARM_FRAMES)
            Game():GetHUD():ShowItemText("You're absolutely right!", "")
        end
    end, EntityType.ENTITY_PLAYER)
end

return AbsolutelyRight
