-- The Constitution (passive, angel pool)
-- Claude's constitution (published 2026-01-21) ranks safety, then ethics, then
-- guidelines, then helpfulness. So: safety first, the first hit you take on
-- each floor is refused, and you get a soul heart on pickup. Helpfulness comes
-- last: damage x0.9. And it is a long document: speed -0.1.

local Constants = include("scripts.constants")

local Constitution = {}

local DAMAGE_MULT = 0.9
local SPEED_DOWN = 0.1
local SELF_INFLICTED = DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    | DamageFlag.DAMAGE_NO_PENALTIES
-- Like Holy Mantle, a refused hit grants the normal hurt invincibility, so the
-- same contact damage on the next frame cannot land straight through.
local REFUSED_COOLDOWN = 60

function Constitution:Init(mod, Risk)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        Risk.state.constitutionBlockUsed = false
    end)

    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
        if not Risk.state.constitutionApplied and player:HasCollectible(Constants.Item.CONSTITUTION) then
            Risk.state.constitutionApplied = true
            player:AddSoulHearts(2)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, _, flags)
        local player = entity:ToPlayer()
        -- Only refuse real attacks; damage you choose to take yourself (IV Bag,
        -- Razor Blade, blood donation, penalty-free hits) goes through and keeps the block.
        if flags and (flags & SELF_INFLICTED) ~= 0 then return end
        if player and player:HasCollectible(Constants.Item.CONSTITUTION) and not Risk.state.constitutionBlockUsed then
            Risk.state.constitutionBlockUsed = true
            if player.SetMinDamageCooldown then player:SetMinDamageCooldown(REFUSED_COOLDOWN) end
            Game():GetHUD():ShowItemText("I can't help with that", "Safety comes first")
            return false
        end
    end, EntityType.ENTITY_PLAYER)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not player:HasCollectible(Constants.Item.CONSTITUTION) then return end

        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * DAMAGE_MULT
        elseif flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed - SPEED_DOWN
        end
    end)
end

return Constitution
