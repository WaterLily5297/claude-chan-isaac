-- Compress nearby ordinary hostile bullets into one native player tear.
-- The shot uses the normal tear pipeline, including character limits/forks.
local Constants = include("scripts.constants")
local Stapler = {}
local RADIUS_SQUARED, MAX_BULLETS = 120 * 120, 12

local function eligible(entity)
    local bullet = entity:ToProjectile()
    if not bullet or not bullet:Exists() or bullet:IsDead()
        or bullet.Variant ~= 0 or bullet.SubType ~= 0
        or bullet.ProjectileFlags ~= 0 or bullet.ChangeFlags ~= 0 then return end
    local owner = bullet.SpawnerEntity and bullet.SpawnerEntity:ToNPC()
    if not owner or owner:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        or bullet:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then return end
    return bullet
end

local function before(a, b)
    if a.distance ~= b.distance then return a.distance < b.distance end
    if a.bullet.InitSeed ~= b.bullet.InitSeed then return a.bullet.InitSeed < b.bullet.InitSeed end
    return a.bullet.Index < b.bullet.Index
end

function Stapler:Init(mod)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if (flags & UseFlag.USE_CARBATTERY) ~= 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        -- One scan per use, bounded nearest-neighbor list; no update callback.
        local selected = {}
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local bullet = eligible(entity)
            if bullet then
                local distance = (bullet.Position - player.Position):LengthSquared()
                if distance <= RADIUS_SQUARED then
                    local entry, index = { bullet = bullet, distance = distance }, 1
                    while selected[index] and not before(entry, selected[index]) do index = index + 1 end
                    if index <= MAX_BULLETS then
                        table.insert(selected, index, entry)
                        if #selected > MAX_BULLETS then table.remove(selected) end
                    end
                end
            end
        end
        if #selected == 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local direction = player:GetShootingInput()
        if direction:LengthSquared() == 0 then
            local directions = {
                [Direction.LEFT] = Vector(-1, 0), [Direction.UP] = Vector(0, -1),
                [Direction.RIGHT] = Vector(1, 0), [Direction.DOWN] = Vector(0, 1),
            }
            direction = directions[player:GetHeadDirection()] or Vector(0, 1)
        end
        for _, entry in ipairs(selected) do entry.bullet:Remove() end
        -- Supply the multiplier at creation; do not overwrite damage/flags after
        -- character and item callbacks have already resolved the shot.
        player:FireTear(player.Position, direction:Resized(6), false, false, false,
            player, 1 + #selected / 4)
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.SUMMARY_STAPLER)
end

return Stapler
