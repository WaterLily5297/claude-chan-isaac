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
    local started, bindings = false, {}
    local function active(player)
        return player and not player:IsDead()
            and not (player.IsCoopGhost and player:IsCoopGhost())
    end
    local function states()
        local all = Risk.state.constitution
        if type(all) ~= "table" or all.version ~= 1 or type(all.players) ~= "table" then
            all = {version = 1, players = {}}
            -- Old saves cannot identify which holder consumed a shared reward.
            -- Preserve those bits for existing players rather than grant duplicates.
            for i = 0, Game():GetNumPlayers() - 1 do
                all.players[tostring(i)] = {
                    applied = Risk.state.constitutionApplied == true,
                    used = Risk.state.constitutionBlockUsed == true,
                }
            end
            Risk.state.constitution = all
            Risk.state.constitutionApplied, Risk.state.constitutionBlockUsed = nil, nil
        end
        return all.players
    end
    local function state(player)
        if not started then return end
        local all = states()
        for i = 0, Game():GetNumPlayers() - 1 do
            local p, key = Isaac.GetPlayer(i), tostring(i)
            -- The Forgotten's Soul is a subplayer with shared inventory, not
            -- a separate co-op slot. Both forms consume the same item state.
            local sub = p.GetSubPlayer and p:GetSubPlayer()
            if GetPtrHash(p) == GetPtrHash(player)
                or (sub and GetPtrHash(sub) == GetPtrHash(player)) then
                local previous, s = bindings[key], all[key]
                if previous and (previous.pointer ~= GetPtrHash(p) or previous.seed ~= p.InitSeed) then
                    s = nil -- A replacement in a live slot cannot inherit a departed holder's reward.
                end
                if type(s) ~= "table" then s = {applied = false, used = false} end
                s.applied, s.used = s.applied == true, s.used == true
                all[key] = s
                bindings[key] = {pointer = GetPtrHash(p), seed = p.InitSeed}
                return s
            end
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        -- Constitution registers before Risk. Read saved state lazily, after
        -- Risk's GAME_STARTED callback has loaded or reset the run.
        started, bindings = true, {}
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        started, bindings = false, {}
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        if not started then return end
        for _, s in pairs(states()) do
            if type(s) == "table" then s.used = false end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
        if not active(player) then return end
        local s = state(player)
        if s and not s.applied and player:HasCollectible(Constants.Item.CONSTITUTION) then
            s.applied = true
            player:AddSoulHearts(2)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, _, flags)
        local player = entity:ToPlayer()
        -- Only refuse real attacks; damage you choose to take yourself (IV Bag,
        -- Razor Blade, blood donation, penalty-free hits) goes through and keeps the block.
        if flags and (flags & SELF_INFLICTED) ~= 0 then return end
        if not active(player) or not player:HasCollectible(Constants.Item.CONSTITUTION) then return end
        local s = state(player)
        if s and not s.used then
            s.used = true
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
