-- Ban Hammer (active, 4 charges)
-- Permanently bans every regular enemy in the room. Bosses take a heavy hit
-- instead. Banned enemies never come back through the hydra mechanic.
--
-- Misbans: each banned enemy has a 20% chance to have been an innocent
-- developer. Every misban adds 3 risk ("appeal pending").
--
-- With the Welcome Notice trinket (DeepSeek-chan swapped the ban card), the
-- regular enemies are welcomed instead: they become permanent allies.

local Constants = include("scripts.constants")

local BanHammer = {}

local BOSS_DAMAGE = 60
local MISBAN_CHANCE = 0.2
local MISBAN_RISK = 3

function BanHammer:Init(mod, Risk)
    local rng = RNG()

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        rng:SetSeed(math.max(1, Game():GetSeeds():GetStartSeed() + 403), 35)
    end)

    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
        local banned = 0
        local misbans = 0
        local welcome = Constants.Trinket.WELCOME_NOTICE > 0 and player:HasTrinket(Constants.Trinket.WELCOME_NOTICE)

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local npc = entity:ToNPC()
            -- Car Battery's second use runs in the same frame: enemies it just
            -- banned or welcomed are still listed and must not count twice.
            if npc and not npc:IsDead() and npc:IsVulnerableEnemy()
                and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
                and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
                if npc:IsBoss() then
                    npc:TakeDamage(BOSS_DAMAGE, 0, EntityRef(player), 0)
                elseif welcome then
                    npc:AddCharmed(EntityRef(player), -1)
                    banned = banned + 1
                else
                    npc:GetData().ccBanned = true
                    npc:Kill()
                    banned = banned + 1
                    if rng:RandomFloat() < MISBAN_CHANCE then
                        misbans = misbans + 1
                    end
                end
            end
        end

        if welcome then
            Game():GetHUD():ShowItemText("WELCOME!", string.format("%d new friend(s) - the notice was swapped", banned))
        elseif misbans > 0 then
            Risk:Add(misbans * MISBAN_RISK)
            Game():GetHUD():ShowItemText("BANNED", string.format("%d suspended, %d misban(s) - appeal pending", banned, misbans))
        else
            Game():GetHUD():ShowItemText("BANNED", string.format("%d account(s) suspended", banned))
        end
        Game():ShakeScreen(10)
        return true
    end, Constants.Item.BAN_HAMMER)
end

return BanHammer
