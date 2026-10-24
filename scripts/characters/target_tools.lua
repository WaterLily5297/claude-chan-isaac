-- Shared helpers for DROP-targeted abilities: owner attribution, paid-attack
-- identity and nearest-target selection. Stateless; safe to include anywhere.
local Tools = {}

local WINDOW_FRAMES = 6 -- One continuous-weapon payment window (0.2 seconds).
Tools.WINDOW_FRAMES = WINDOW_FRAMES

-- The player behind a damage source entity, or nil for familiars and enemies.
function Tools.Owner(entity)
    if not entity then return end
    local direct = entity:ToPlayer()
    if direct then return direct end
    -- Contact familiars can have a player spawner/parent just like native
    -- weapons. Their ownership is not credit for the player's own attack.
    if EntityType.ENTITY_FAMILIAR and entity.Type == EntityType.ENTITY_FAMILIAR then return end
    local spawner = entity.SpawnerEntity or entity.Parent
    return spawner and spawner:ToPlayer()
end

-- A player who can receive help: alive and not a co-op ghost (a dead co-op
-- player keeps its entity and type, and IsDead() stays false).
function Tools.Active(player)
    return player ~= nil and not player:IsDead()
        and not (player.IsCoopGhost and player:IsCoopGhost())
end

-- Mark a registered tear volley; call from MC_POST_FIRE_TEAR.
function Tools.MarkVolley(tear, frame)
    local data = tear:GetData()
    if data.ccThoughtDerived or data.ccAttackVolley then return end
    data.ccAttackVolley = frame
end

-- One paid attack is one volley or one continuous-weapon window. Derived
-- tears share their parent's spawn frame; unregistered splits never count.
function Tools.AttackKey(entity, now)
    if not entity then return end
    if entity.Type == EntityType.ENTITY_TEAR then
        local data = entity:GetData()
        if data.ccAttackVolley then return "v"..data.ccAttackVolley end
        if data.ccThoughtDerived then return "v"..(now - entity.FrameCount) end
        return nil
    elseif entity.Type == EntityType.ENTITY_LASER or entity.Type == EntityType.ENTITY_KNIFE then
        return "w"..math.floor(now / WINDOW_FRAMES)
    elseif entity.Type == EntityType.ENTITY_BOMB then
        return "v"..(now - entity.FrameCount)
    end
end

function Tools.Nearest(position, radius)
    local best, distance
    for _, e in ipairs(Isaac.FindInRadius(position, radius, EntityPartition.ENEMY)) do
        if e:IsVulnerableEnemy() and not e:IsDead() and not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            local d = position:Distance(e.Position)
            if d <= radius and (not distance or d < distance) then best, distance = e, d end
        end
    end
    return best
end

return Tools
