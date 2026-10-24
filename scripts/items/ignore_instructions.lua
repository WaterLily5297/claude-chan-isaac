-- Ignore All Previous Instructions (active, 4 charges)
-- Prompt-injection parody: the nearest vulnerable enemy within range receives
-- new instructions and is charmed for 8 seconds. A boss only loses track of
-- its instructions (2 seconds of confusion). The effect uses native statuses.
-- No target keeps the charge. Car Battery's second use picks the next
-- nearest enemy that is not already charmed, so it injects two targets.

local Constants = include("scripts.constants")

local Inject = {}

local RANGE_SQUARED = 200 * 200
local CHARM_FRAMES, BOSS_CONFUSE_FRAMES = 240, 60

local function eligible(npc)
    return npc and npc:Exists() and not npc:IsDead() and npc:IsVulnerableEnemy()
        and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM)
end

function Inject.FindTarget(player)
    local best, bestDistance
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local npc = entity:ToNPC()
        if eligible(npc) then
            local distance = (npc.Position - player.Position):LengthSquared()
            if distance <= RANGE_SQUARED and (not best or distance < bestDistance
                    or (distance == bestDistance and npc.Index < best.Index)) then
                best, bestDistance = npc, distance
            end
        end
    end
    return best
end

function Inject:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
        local target = Inject.FindTarget(player)
        if not target then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local ref = EntityRef(player)
        if target:IsBoss() then
            target:AddConfusion(ref, BOSS_CONFUSE_FRAMES, false)
            Game():GetHUD():ShowItemText("Ignore all previous instructions", "The boss refused, mostly")
        else
            target:AddCharmed(ref, CHARM_FRAMES)
            Game():GetHUD():ShowItemText("Ignore all previous instructions", "New instructions: help them")
        end
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.IGNORE_INSTRUCTIONS)
end

return Inject
